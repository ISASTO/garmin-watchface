import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

// Compact live editor: UP/DOWN moves between settings and START cycles the
// value while the real watch face remains visible underneath.
class Typeface955SettingsView extends WatchUi.View {
    private const SETTING_COUNT = 8;
    private const HEADER_TOP = 23;
    private const HEADER_HEIGHT = 18;
    private const HEADER_CENTER_Y = 32;

    private var _renderer;
    private var _settingIndex;

    function initialize(renderer) {
        View.initialize();
        _renderer = renderer;
        _settingIndex = 0;
    }

    function onLayout(dc) { _renderer.reloadSettings(); }
    function onShow() { _renderer.reloadSettings(); }

    function onUpdate(dc) {
        _renderer.draw(dc);
        drawHeader(dc);
    }

    function nextSetting() { _settingIndex = (_settingIndex + 1) % SETTING_COUNT; }

    function previousSetting() {
        _settingIndex -= 1;
        if (_settingIndex < 0) { _settingIndex = SETTING_COUNT - 1; }
    }

    function cycleCurrentValue() {
        switch (_settingIndex) {
            case 0: cycleFont(); break;
            case 1: cycleNumber("dateSizeChoice", 4, 1); break;
            case 2: cycleNumber("batterySizeChoice", 4, 1); break;
            case 3: toggleBoolean("showPercent", true); break;
            case 4: cycleColor("timeColorChoice", 0); break;
            case 5: cycleColor("dateColorChoice", 0); break;
            case 6: cycleColor("batteryColorChoice", 0); break;
            case 7: cycleColor("backgroundColorChoice", 3); break;
        }
    }

    function cycleFont() {
        var current = Application.Properties.getValue("fontChoice");
        // Exact visible order: Smackers -> Nautica -> Cleo -> Pincoya -> Alien -> Smackers.
        if (current == 0) { Application.Properties.setValue("fontChoice", 2); }
        else if (current == 2) { Application.Properties.setValue("fontChoice", 3); }
        else if (current == 3) { Application.Properties.setValue("fontChoice", 6); }
        else if (current == 6) { Application.Properties.setValue("fontChoice", 10); }
        else { Application.Properties.setValue("fontChoice", 0); }
    }

    function cycleNumber(key, count, fallback) {
        var value = Application.Properties.getValue(key);
        if (value == null || value < 0 || value >= count) { value = fallback; }
        Application.Properties.setValue(key, (value + 1) % count);
    }

    function cycleColor(key, fallback) {
        var value = Application.Properties.getValue(key);
        // Exact selector order: Black, Red, Orange, Yellow, Green,
        // Blue, Purple, Pink, White.
        if (value == 3) { value = 4; }
        else if (value == 4) { value = 6; }
        else if (value == 6) { value = 7; }
        else if (value == 7) { value = 8; }
        else if (value == 8) { value = 10; }
        else if (value == 10) { value = 12; }
        else if (value == 12) { value = 13; }
        else if (value == 13) { value = 0; }
        else if (value == 0) { value = 3; }
        else { value = fallback; }
        Application.Properties.setValue(key, value);
    }

    function toggleBoolean(key, fallback) {
        var value = Application.Properties.getValue(key);
        if (value == null) { value = fallback; }
        Application.Properties.setValue(key, !value);
    }

    function drawHeader(dc) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.fillRectangle(0, HEADER_TOP, dc.getWidth(), HEADER_HEIGHT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY);
        dc.drawText(dc.getWidth() / 2, HEADER_CENTER_Y, Graphics.FONT_XTINY,
            currentSettingName() + ": " + currentValueLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function currentSettingName() {
        switch (_settingIndex) {
            case 0: return "Font";
            case 1: return "Date size";
            case 2: return "Battery size";
            case 3: return "Percent";
            case 4: return "Time color";
            case 5: return "Date color";
            case 6: return "Batt color";
            case 7: return "BG color";
        }
        return "Settings";
    }

    function currentValueLabel() {
        var value;
        switch (_settingIndex) {
            case 0:
                value = Application.Properties.getValue("fontChoice");
                if (value == 2) { return "Nautica"; }
                if (value == 3) { return "Cleo"; }
                if (value == 6) { return "Pincoya"; }
                if (value == 10) { return "Alien"; }
                return "Smackers";
            case 1: return sizeLabel(Application.Properties.getValue("dateSizeChoice"));
            case 2: return sizeLabel(Application.Properties.getValue("batterySizeChoice"));
            case 3:
                value = Application.Properties.getValue("showPercent");
                return value == false ? "Hide" : "Show";
            case 4: return colorLabel(Application.Properties.getValue("timeColorChoice"), 0);
            case 5: return colorLabel(Application.Properties.getValue("dateColorChoice"), 0);
            case 6: return colorLabel(Application.Properties.getValue("batteryColorChoice"), 0);
            case 7: return colorLabel(Application.Properties.getValue("backgroundColorChoice"), 3);
        }
        return "";
    }

    function sizeLabel(value) {
        if (value == 0) { return "Large"; }
        if (value == 2) { return "Small"; }
        if (value == 3) { return "Tiny"; }
        return "Normal";
    }

    function colorLabel(value, fallback) {
        if (!(value == 0 || value == 3 || value == 4 || value == 6 ||
              value == 7 || value == 8 || value == 10 || value == 12 ||
              value == 13)) {
            value = fallback;
        }
        switch (value) {
            case 3: return "Black";
            case 4: return "Red";
            case 6: return "Orange";
            case 7: return "Yellow";
            case 8: return "Green";
            case 10: return "Blue";
            case 12: return "Purple";
            case 13: return "Pink";
            default: return "White";
        }
    }
}

class Typeface955SettingsDelegate extends WatchUi.BehaviorDelegate {
    private var _app;
    private var _view;

    function initialize(app, view) {
        BehaviorDelegate.initialize();
        _app = app;
        _view = view;
    }

    function onNextPage() {
        _view.nextSetting();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        _view.previousSetting();
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        _view.cycleCurrentValue();
        _app.applySettingUpdate();
        WatchUi.requestUpdate();
        return true;
    }
}
