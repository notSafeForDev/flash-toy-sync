import Components.JSONLoader;
import Global.GlobalEvents;

import Models.UserConfigModel;

class Controllers.UserConfigController {
	
	function UserConfigController() {
		JSONLoader.load("UserConfig.json", function (json : Object) {
			UserConfigModel.connectionKey = json.connectionKey;
			UserConfigModel.editorEnabled = json.editorEnabled;
			UserConfigModel.fullscreenButton = json.fullscreenButton;
			GlobalEvents.events.userConfig.loaded.emit({config: json});
		});
	}
}