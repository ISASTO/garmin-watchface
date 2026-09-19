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
        // Draw the complete frame on every Garmin callback. The watch controls
        // low-power update frequency; the renderer keeps unchanged data cached.
        _renderer.draw(dc);
    }
}
