import Toybox.Application;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Shared renderer for the normal face and the live settings preview.
// Battery-optimized for the Forerunner 955's watch-face lifecycle.
class Typeface955Renderer {
    // Fixed 260x260 Forerunner 955 geometry. Avoid querying width every frame.
    private const CENTER_X = 130;
    private const DATE_Y = 57;
    private const TIME_Y = 130;
    private const BATTERY_Y = 203;
    private const CLEO_TIME_Y_OFFSET = -8;
    private const TEXT_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private const SUN = "SUN";
    private const MON = "MON";
    private const TUE = "TUE";
    private const WED = "WED";
    private const THU = "THU";
    private const FRI = "FRI";
    private const SAT = "SAT";

    private var _timeFont;
    private var _dateFont;
    private var _batteryFont;

    private var _fontChoice;
    private var _dateSizeChoice;
    private var _batterySizeChoice;
    private var _showPercent;

    private var _dateColor;
    private var _timeColor;
    private var _batteryColor;
    private var _backgroundColor;
    private var _timeY;

    private var _loadedFontChoice;
    private var _loadedDateSize;
    private var _loadedBatterySize;

    // Display-data cache. Garmin calls onUpdate() every second for roughly ten
    // seconds after a wrist gesture, even though this face contains no seconds.
    // We still draw a complete frame on every callback (required on real 955
    // hardware), but avoid re-querying/reformatting unchanged data.
    private var _cachedHour;
    private var _cachedMinute;
    private var _timeText;
    private var _dateText;
    private var _batteryText;
    private var _cachedBatteryValue;
    private var _batteryComplicationId;
    private var _batterySubscriptionActive;

    function initialize() {
        _timeFont = null;
        _dateFont = null;
        _batteryFont = null;

        _fontChoice = 0;
        _dateSizeChoice = 1;
        _batterySizeChoice = 1;
        _showPercent = true;

        _dateColor = Graphics.COLOR_WHITE;
        _timeColor = Graphics.COLOR_WHITE;
        _batteryColor = Graphics.COLOR_WHITE;
        _backgroundColor = Graphics.COLOR_BLACK;
        _timeY = TIME_Y;

        _loadedFontChoice = -1;
        _loadedDateSize = -1;
        _loadedBatterySize = -1;

        _cachedHour = -1;
        _cachedMinute = -1;
        _timeText = null;
        _dateText = null;
        _batteryText = null;
        _cachedBatteryValue = null;
        _batteryComplicationId = null;
        _batterySubscriptionActive = false;
    }

    function invalidateDataCache() {
        _cachedHour = -1;
        _cachedMinute = -1;
        _timeText = null;
        _dateText = null;
    }

    function startBatteryUpdates() {
        // Battery is a native Garmin complication on the Forerunner 955.
        // Subscribe once so Garmin tells us when the percentage actually
        // changes instead of polling System.getSystemStats() every hour.
        try {
            _batteryComplicationId = new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY);
            Complications.registerComplicationChangeCallback(self.method(:onBatteryComplicationChanged));
            _batterySubscriptionActive = Complications.subscribeToUpdates(_batteryComplicationId);

            if (_batterySubscriptionActive) {
                refreshBatteryFromComplication();
            }
        } catch (e) {
            _batterySubscriptionActive = false;
        }

        // Defensive fallback for a firmware/API failure. This is normally not
        // used on the 955, which officially supports battery complications.
        if (!_batterySubscriptionActive) {
            sampleBatteryFallback();
        }
    }

    function stopBatteryUpdates() {
        if (_batterySubscriptionActive && _batteryComplicationId != null) {
            try {
                Complications.unsubscribeFromUpdates(_batteryComplicationId);
            } catch (e) {
            }
        }

        try {
            Complications.registerComplicationChangeCallback(null);
        } catch (e) {
        }

        _batterySubscriptionActive = false;
    }

    function onBatteryComplicationChanged(complicationId as Complications.Id) as Void {
        if (_batteryComplicationId == null || !complicationId.equals(_batteryComplicationId)) {
            return;
        }

        if (refreshBatteryFromComplication()) {
            // While charging the native value can change several times between
            // normal watch-face samples. Redraw only when Garmin publishes one.
            WatchUi.requestUpdate();
        }
    }

    function refreshBatteryNow() {
        // onShow() uses this so the first glance after charging is current even
        // if the face was not visible when a complication notification arrived.
        if (_batterySubscriptionActive) {
            refreshBatteryFromComplication();
        } else {
            sampleBatteryFallback();
        }
    }

    function refreshBatteryFromComplication() {
        if (_batteryComplicationId == null) {
            return false;
        }

        try {
            var battery = Complications.getComplication(_batteryComplicationId);
            if (battery.value == null) {
                return false;
            }

            _cachedBatteryValue = battery.value;
            rebuildBatteryText();
            return true;
        } catch (e) {
            return false;
        }
    }

    function sampleBatteryFallback() {
        _cachedBatteryValue = System.getSystemStats().battery;
        rebuildBatteryText();
    }

    function rebuildBatteryText() {
        if (_cachedBatteryValue == null) {
            _batteryText = null;
            return;
        }

        _batteryText = _cachedBatteryValue.format("%.0f") + (_showPercent ? "%" : "");
    }

    function reloadSettings() {
        var oldShowPercent = _showPercent;

        _fontChoice = normalizeFontChoice(Application.Properties.getValue("fontChoice"));
        _dateSizeChoice = normalizeFourChoice(Application.Properties.getValue("dateSizeChoice"), 1);
        _batterySizeChoice = normalizeFourChoice(Application.Properties.getValue("batterySizeChoice"), 1);

        var showPercent = Application.Properties.getValue("showPercent");
        _showPercent = showPercent == null ? true : showPercent;

        _dateColor = colorForChoice(normalizeColorChoice(Application.Properties.getValue("dateColorChoice"), 0));
        _timeColor = colorForChoice(normalizeColorChoice(Application.Properties.getValue("timeColorChoice"), 0));
        _batteryColor = colorForChoice(normalizeColorChoice(Application.Properties.getValue("batteryColorChoice"), 0));
        _backgroundColor = colorForChoice(normalizeColorChoice(Application.Properties.getValue("backgroundColorChoice"), 3));
        _timeY = TIME_Y + (_fontChoice == 3 ? CLEO_TIME_Y_OFFSET : 0);

        loadTimeFontIfNeeded();
        loadDateFontIfNeeded();
        loadBatteryFontIfNeeded();

        // Reformat the already-cached value; do not perform a new battery query.
        if (oldShowPercent != _showPercent) {
            rebuildBatteryText();
        }
    }

    function normalizeFontChoice(choice) {
        if (choice == 0 || choice == 2 || choice == 3 || choice == 6 || choice == 10) {
            return choice;
        }
        return 0;
    }

    function normalizeFourChoice(choice, fallback) {
        if (choice == null || choice < 0 || choice > 3) {
            return fallback;
        }
        return choice;
    }

    function normalizeColorChoice(choice, fallback) {
        if (choice == 0 || choice == 3 || choice == 4 || choice == 6 ||
            choice == 7 || choice == 8 || choice == 10 || choice == 12 ||
            choice == 13) {
            return choice;
        }
        return fallback;
    }

    function loadTimeFontIfNeeded() {
        if (_timeFont != null && _fontChoice == _loadedFontChoice) {
            return;
        }
        _timeFont = null;

        switch (_fontChoice) {
            case 2: _timeFont = WatchUi.loadResource(Rez.Fonts.TimeNautica); break;
            case 3: _timeFont = WatchUi.loadResource(Rez.Fonts.TimeCleoFolk); break;
            case 6: _timeFont = WatchUi.loadResource(Rez.Fonts.TimePincoyaBlack); break;
            case 10: _timeFont = WatchUi.loadResource(Rez.Fonts.TimeAlienPlanet); break;
            default: _timeFont = WatchUi.loadResource(Rez.Fonts.TimeSmackers); break;
        }
        _loadedFontChoice = _fontChoice;
    }

    function loadDateFontIfNeeded() {
        if (_dateFont != null && _dateSizeChoice == _loadedDateSize) {
            return;
        }
        _dateFont = null;

        switch (_dateSizeChoice) {
            case 0: _dateFont = WatchUi.loadResource(Rez.Fonts.InfoTommyLarge); break;
            case 2: _dateFont = WatchUi.loadResource(Rez.Fonts.InfoTommySmall); break;
            case 3: _dateFont = WatchUi.loadResource(Rez.Fonts.InfoTommyTiny); break;
            default: _dateFont = WatchUi.loadResource(Rez.Fonts.InfoTommy); break;
        }
        _loadedDateSize = _dateSizeChoice;
    }

    function loadBatteryFontIfNeeded() {
        if (_batteryFont != null && _batterySizeChoice == _loadedBatterySize) {
            return;
        }
        _batteryFont = null;

        switch (_batterySizeChoice) {
            case 0: _batteryFont = WatchUi.loadResource(Rez.Fonts.BatteryTommyLarge); break;
            case 2: _batteryFont = WatchUi.loadResource(Rez.Fonts.BatteryTommySmall); break;
            case 3: _batteryFont = WatchUi.loadResource(Rez.Fonts.BatteryTommyTiny); break;
            default: _batteryFont = WatchUi.loadResource(Rez.Fonts.BatteryTommy); break;
        }
        _loadedBatterySize = _batterySizeChoice;
    }

    function colorForChoice(choice) {
        switch (choice) {
            case 3: return Graphics.COLOR_BLACK;
            case 4: return Graphics.COLOR_RED;
            case 6: return Graphics.COLOR_ORANGE;
            case 7: return Graphics.COLOR_YELLOW;
            case 8: return Graphics.COLOR_GREEN;
            case 10: return Graphics.COLOR_BLUE;
            case 12: return Graphics.COLOR_PURPLE;
            case 13: return Graphics.COLOR_PINK;
            default: return Graphics.COLOR_WHITE;
        }
    }

    function weekdayText(dayOfWeek) {
        switch (dayOfWeek) {
            case 1: return SUN;
            case 2: return MON;
            case 3: return TUE;
            case 4: return WED;
            case 5: return THU;
            case 6: return FRI;
            default: return SAT;
        }
    }

    function updateCachedData() {
        // This remains the only normal per-callback system query.
        var clock = System.getClockTime();
        var hourChanged = (clock.hour != _cachedHour);
        var minuteChanged = (clock.min != _cachedMinute) || hourChanged || _timeText == null;

        if (minuteChanged) {
            _cachedHour = clock.hour;
            _cachedMinute = clock.min;
            _timeText = clock.hour.format("%02d") + clock.min.format("%02d");
        }

        // Calendar work stays hourly. Battery is event-driven through Garmin
        // complications and therefore does not belong in the normal hot path.
        if (hourChanged || _dateText == null) {
            var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            _dateText = weekdayText(today.day_of_week) + " " + today.day.format("%d");
        }

        // If native complication subscription was unavailable, preserve the
        // old once-per-hour system-stats fallback.
        if (!_batterySubscriptionActive && (hourChanged || _batteryText == null)) {
            sampleBatteryFallback();
        }
    }

    function draw(dc) {
        if (_timeFont == null || _dateFont == null || _batteryFont == null) {
            reloadSettings();
        }

        updateCachedData();

        // A complete frame is deliberately redrawn on every Garmin callback.
        // Returning without drawing can yield a black frame on the physical 955.
        dc.setColor(_backgroundColor, _backgroundColor);
        dc.clear();

        dc.setColor(_dateColor, _backgroundColor);
        dc.drawText(CENTER_X, DATE_Y, _dateFont, _dateText, TEXT_JUSTIFY);

        dc.setColor(_timeColor, _backgroundColor);
        dc.drawText(CENTER_X, _timeY, _timeFont, _timeText, TEXT_JUSTIFY);

        dc.setColor(_batteryColor, _backgroundColor);
        dc.drawText(CENTER_X, BATTERY_Y, _batteryFont, _batteryText, TEXT_JUSTIFY);
    }
}
