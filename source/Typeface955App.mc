import Toybox.Application;
import Toybox.WatchUi;

class Typeface955App extends Application.AppBase {
    private var _renderer;
    private var _mainView;

    function initialize() {
        AppBase.initialize();
        _renderer = new Typeface955Renderer();
        _mainView = null;
    }

    function onStart(state) {
        _renderer.startBatteryUpdates();
    }

    function onStop(state) {
        _renderer.stopBatteryUpdates();
    }

    function getInitialView() {
        _renderer.reloadSettings();
        _mainView = new Typeface955View(_renderer);
        return [_mainView];
    }

    function getSettingsView() {
        _renderer.reloadSettings();
        var settingsView = new Typeface955SettingsView(_renderer);
        return [settingsView, new Typeface955SettingsDelegate(self, settingsView)];
    }

    function applySettingUpdate() {
        _renderer.reloadSettings();
        if (_mainView != null) {
            _mainView.reloadSettings();
        }
    }

    function onSettingsChanged() {
        applySettingUpdate();
        WatchUi.requestUpdate();
    }
}
