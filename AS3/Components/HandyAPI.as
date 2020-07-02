package Components {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class HandyAPI {
		
		public var connectionKey : String = "";
		
		private var hasSyncData : Boolean = false;
		private var apiPath : String = "https://www.handyfeeling.com/api/v1";
		
		function HandyAPI() {
			
		}
		
		public function send(position : Number, durationMiliseconds : Number) {
			if (connectionKey == "") {
				throw "Unable to send handy command, no connection key have been set";
			}
			
			var minDuration : Number = 150;
			durationMiliseconds = Math.max(durationMiliseconds, minDuration);
			var url : String = apiPath + "/" + connectionKey + "/?cmd=setPosition&position=" + position + "&type=%&time=" + durationMiliseconds;
			
			var syncLoader : URLLoader = new URLLoader();
			
			syncLoader.load(getURLRequest(url));
		}
		
		public function prepareSync(csvUrl : String, _onSynced : Function = null) {
			if (connectionKey == "") {
				throw "Unable prepare syncing, no connection key have been set";
			}
			
			// The size is randomized as it won't download the file if the name and size matches a previously downloaded file
			var size : int = Math.floor(Math.random() * 1000);
			var url : String = apiPath + "/" + connectionKey + "/syncPrepare?url=" + csvUrl + "&name=test&size=" + size + "&timeout=20000";
			var syncLoader : URLLoader = new URLLoader();
			
			syncLoader.addEventListener(Event.COMPLETE, function(e : Event) {
				hasSyncData = true;
				if (_onSynced != null) {
					_onSynced(JSON.parse(syncLoader.data));
				}
			});
			
			syncLoader.load(getURLRequest(url));
		}
		
		public function syncPlay(time : Number, _onPlay : Function = null) {
			if (connectionKey == "") {
				throw "Unable to play sync, no connection key have been set";
			}
			if (hasSyncData == false) {
				throw "Unable to play sync, there is no sync data";
			}
			
			var playLoader : URLLoader = new URLLoader();
		
			playLoader.addEventListener(Event.COMPLETE, function(e : Event) {
				if (_onPlay != null) {
					_onPlay(JSON.parse(playLoader.data));
				}
			});
			
			playLoader.load(getURLRequest(apiPath + "/" + connectionKey + "/syncPlay?play=true&time=" + time));
		}
		
		public function syncStop(_onStop : Function = null) {
			if (connectionKey == "") {
				throw "Unable to stop sync, no connection key have been set";
			}
			if (hasSyncData == false) {
				throw "Unable to stop sync, there is no sync data";
			}
			
			var playLoader : URLLoader = new URLLoader();
		
			playLoader.addEventListener(Event.COMPLETE, function(e : Event) {
				if (_onStop != null) {
					_onStop(JSON.parse(playLoader.data));
				}
			});
			
			playLoader.load(getURLRequest(apiPath + "/" + connectionKey + "/syncPlay?play=false"));
		}
		
		public function getURLRequest(_url : String) {
			// The server response is cached and reuesed when the same url is used again, so we add a unique value at the end
			if (_url.indexOf("?") >= 0) {
				_url += "&cachekill=" + new Date();
			}
			else {
				_url += "?cachekill=" + new Date();
			}
			
			return new URLRequest(_url);
		}
	}
}