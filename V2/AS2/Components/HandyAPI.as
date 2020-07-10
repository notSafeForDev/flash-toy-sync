import Core.JSON;

class Components.HandyAPI {
	
	var connectionKey : String = "";
	
	var isPlayingSync : Boolean = false;
	
	private var hasSyncData : Boolean = false;
	private var apiPath : String = "https://www.handyfeeling.com/api/v1";
	
	function HandyCommands() {
		
	}
	
	public function setPosition(_position : Number, _durationMiliseconds : Number) {
		if (connectionKey == "") {
			throw "Unable to set position, no connection key have been set";
		}
		
		var minDuration : Number = 150;
		_durationMiliseconds = Math.max(_durationMiliseconds, minDuration);
		
		var loader : LoadVars = new LoadVars();
		var url : String = apiPath + "/" + connectionKey + "/?cmd=setPosition&position=" + _position + "&type=%&time=" + _durationMiliseconds;
		loader.load(url, loader, "GET");
		
		isPlayingSync = false;
	}
	
	public function syncPrepare(_csvUrl : String, _onSynced : Function) {
		var self = this;
	
		if (connectionKey == "") {
			throw "Unable to prepare sync, no connection key have been set";
		}
		
		// The size is randomized as it won't download the file if the name and size matches a previously downloaded file
		var size : Number = Math.floor(Math.random() * 1000);
		var url : String = apiPath + "/" + connectionKey + "/syncPrepare?url=" + _csvUrl + "&name=test&size=" + size + "&timeout=20000";
		var loader : LoadVars = new LoadVars();
	
		loader.onData = function(_data : String) {
			self.hasSyncData = true;
			_onSynced(JSON.parse(_data));
		}
		
		loader.load(url, syncLoader, "GET");
	}
	
	public function syncPlay(_time : Number, _onPlay : Function) {
		if (connectionKey == "") {
			throw "Unable to play sync, no connection key have been set";
		}
		if (hasSyncData == false) {
			throw "Unable to play sync, there is no sync data";
		}
		
		var loader : LoadVars = new LoadVars();
	
		loader.onData = function(loadedPlayData : String) {
			if (_onPlay != undefined) {
				_onPlay(JSON.parse(loadedPlayData));
			}
		}
		
		loader.load(apiPath + "/" + connectionKey + "/syncPlay?play=true&time=" + _time, playLoader, "GET");
		
		isPlayingSync = true;
	}
	
	public function syncStop(onStop) {
		if (connectionKey == "") {
			throw "Unable to stop sync, no connection key have been set";
		}
		if (hasSyncData == false) {
			throw "Unable to stop sync, there is no sync data";
		}
		
		var playLoader : LoadVars = new LoadVars();
	
		playLoader.onData = function(loadedPlayData) {
			if (onStop != undefined) {
				onStop(loadedPlayData);
			}
		}
		
		playLoader.load(apiPath + "/" + connectionKey + "/syncPlay?play=false", playLoader, "GET");
		
		isPlayingSync = false;
	}
}