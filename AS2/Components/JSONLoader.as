import flash.net.FileReference;
import Components.JSON;

class Components.JSONLoader {
	
	static function browse(pathPrefix : String, onResponse : Function) {		
		var fileReference : FileReference = new FileReference();
		var jsonLoader : LoadVars = new LoadVars();
		var listener : Object = new Object();
		
		fileReference.addListener(listener);
		fileReference.browse([{description: "json", extension: "*.json"}]);
		
		listener.onSelect = function(file : FileReference) {
			JSONLoader.load(pathPrefix + file.name, onResponse);
		}
		
		listener.onCancel = function(file : FileReference) {
			trace("onCancel");
		}
		
		listener.onOpen = function(file:FileReference):Void {
			trace("onOpen: " + file.name);
		}
		
		listener.onProgress = function(file:FileReference, bytesLoaded:Number, bytesTotal:Number):Void {
			trace("onProgress with bytesLoaded: " + bytesLoaded + " bytesTotal: " + bytesTotal);
		}
		
		listener.onComplete = function(file:FileReference):Void {
			trace("onComplete: " + file.name);
		}
		
		listener.onIOError = function(file:FileReference):Void {
			trace("onIOError: " + file.name);
		}
		
		/* jsonLoader.onLoad = function(success : Boolean) {
			if (success == false) {
				trace("Unable to load json file");
			}
		};
		
		jsonLoader.onData = function(loadedData) {
			try {
				var json : Object = JSON.parse(loadedData);
				trace(onResponse);
				onResponse(json);
			} catch (error) {
				trace(error.name + ":" + error.message + ":" + error.at + ":" + error.text);
				onResponse(undefined);
			}
		}; */
	}
	
	static function load(path : String, onResponse : Function) {		
		var jsonLoader : LoadVars = new LoadVars();
		
		jsonLoader.onLoad = function(success : Boolean) {
			if (success == false) {
				trace("Unable to load json file");
			}
		};
		
		jsonLoader.onData = function(loadedData) {
			try {
				var json : Object = JSON.parse(loadedData);
				onResponse(json);
			} catch (error) {
				trace(error.name + ":" + error.message + ":" + error.at + ":" + error.text);
				onResponse(undefined);
			}
		};
		
		jsonLoader.load(path);
	}
}