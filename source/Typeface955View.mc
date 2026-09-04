import Toybox.WatchUi;

class Typeface955View extends WatchUi.WatchFace {
    private var _renderer;

    function initialize(renderer) {
        WatchFace.initialize();
        _renderer = renderer;
    }

    function onLayout(dc) {
        _renderer.reloadSettings();
    }

    function onShow() {
        _renderer.reloadSettings();
        _renderer.refreshBatteryNow();
    }

    function reloadSettings() {
        _renderer.reloadSettings();
    }

    function onUpdate(dc) {
        // Draw the complete frame on every Garmin onUpdate callback. The 955
        // throttles low-power watch-face updates itself; skipping a requested
        // redraw can produce a black frame on real hardware.
        _renderer.draw(dc);
    }
}
