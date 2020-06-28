import Components.JSON;

class Components.HandyCommands {
	
	var connectionKey : String = "";
	
	private var hasSyncData : Boolean = false;
	private var apiPath : String = "https://www.handyfeeling.com/api/v1";
	
	function HandyCommands() {
		
	}
	
	public function send(position : Number, durationMiliseconds : Number) {
		if (connectionKey == "") {
			throw "Unable to send handy command, no connection key have been set";
		}
		
		var minDuration : Number = 150;
		durationMiliseconds = Math.max(durationMiliseconds, minDuration);
		
		var loader : LoadVars = new LoadVars();
		var url : String = apiPath + "/" + connectionKey + "/?cmd=setPosition&position=" + position + "&type=%&time=" + durationMiliseconds;
		loader.load(url, loader, "GET");
	}
	
	public function prepareSync(csvUrl : String, onSynced : Function) {
		var self = this;
	
		if (connectionKey == "") {
			throw "Unable prepare syncing, no connection key have been set";
		}
		
		// The size is randomized as it won't download the file if the name and size matches a previously downloaded file
		var size : Number = Math.floor(Math.random() * 1000);
		var url : String = apiPath + "/" + connectionKey + "/syncPrepare?url=" + csvUrl + "&name=test&size=" + size + "&timeout=20000";
		var syncLoader : LoadVars = new LoadVars();
	
		syncLoader.onData = function(loadedPlayData : String) {
			self.hasSyncData = true;
			onSynced(JSON.parse(loadedPlayData));
		}
		
		syncLoader.load(url, syncLoader, "GET");
	}
	
	public function syncPlay(time : Number, onPlay : Function) {
		if (connectionKey == "") {
			throw "Unable to play sync, no connection key have been set";
		}
		if (hasSyncData == false) {
			throw "Unable to play sync, there is no sync data";
		}
		
		var playLoader : LoadVars = new LoadVars();
	
		playLoader.onData = function(loadedPlayData : String) {
			if (onPlay != undefined) {
				onPlay(JSON.parse(loadedPlayData));
			}
		}
		
		playLoader.load(apiPath + "/" + connectionKey + "/syncPlay?play=true&time=" + time, playLoader, "GET");
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
	}
}