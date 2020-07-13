package Components {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class HandyAPI {
		public static var MODE_OFF = 0;
		public static var MODE_AUTOMATIC = 1;
		public static var MODE_POSITION = 2;
		public static var MODE_CALIBRATION = 3;
		public static var MODE_SYNC = 4;
		
		public var connectionKey : String = "";
		
		public var isPlayingSync : Boolean = false;
		
		private var hasSyncData : Boolean = false;
		private var apiPath : String = "https://www.handyfeeling.com/api/v1";
		
		function HandyAPI() {
			
		}
		
		public function setMode(_mode : Number, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to set mode, no connection key have been set";
			}
			
			var url : String = apiPath + "/" + connectionKey + "/?cmd=setMode&mode=" + _mode;
			sendURLRequest(url, _onResponse);
			isPlayingSync = false;
		}
		
		public function setPosition(_position : Number, _durationMiliseconds : Number, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to set position, no connection key have been set";
			}
			
			var minDuration : Number = 150;
			_durationMiliseconds = Math.max(_durationMiliseconds, minDuration);
			var url : String = apiPath + "/" + connectionKey + "/?cmd=setPosition&position=" + _position + "&type=%&time=" + _durationMiliseconds;
			sendURLRequest(url, _onResponse);
			isPlayingSync = false;
		}
		
		public function setSpeed(_speed : Number, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to set speed, no connection key have been set";
			}
			
			setMode(HandyAPI.MODE_AUTOMATIC);
			
			var url : String = apiPath + "/" + connectionKey + "/?cmd=setSpeed&speed=" + _speed * 100 + "&type=%";
			sendURLRequest(url, _onResponse);
			isPlayingSync = false;
		}
		
		public function setLength(_length : Number, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to set length, no connection key have been set";
			}
			
			var url : String = apiPath + "/" + connectionKey + "/?cmd=setStroke&stroke=" + _length * 100 + "&type=%";
			sendURLRequest(url, _onResponse);
			isPlayingSync = false;
		}
		
		public function syncPrepare(_csvUrl : String, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to prepare sync, no connection key have been set";
			}
			
			function onResponse(_response : Object) {
				hasSyncData = true;
				_onResponse(_response);
			}
			
			// The size is randomized as it won't download the file if the name and size matches a previously downloaded file
			var size : int = Math.floor(Math.random() * 1000);
			var url : String = apiPath + "/" + connectionKey + "/syncPrepare?url=" + _csvUrl + "&name=test&size=" + size + "&timeout=20000";
			sendURLRequest(url, onResponse);
		}
		
		public function syncPlay(_time : Number, _onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to play sync, no connection key have been set";
			}
			if (hasSyncData == false) {
				throw "Unable to play sync, there is no sync data";
			}
			
			var url : String = apiPath + "/" + connectionKey + "/syncPlay?play=true&time=" + _time;
			sendURLRequest(url, _onResponse);
			isPlayingSync = true;
		}
		
		public function syncStop(_onResponse : Function = null) {
			if (connectionKey == "") {
				throw "Unable to stop sync, no connection key have been set";
			}
			if (hasSyncData == false) {
				throw "Unable to stop sync, there is no sync data";
			}
			
			var url : String = apiPath + "/" + connectionKey + "/syncPlay?play=false";
			sendURLRequest(url, _onResponse);
			isPlayingSync = false;
		}
		
		private function sendURLRequest(_url : String, _onResponse : Function = null) {
			// The server response is cached and reuesed when the same url is used again, so we add a unique value at the end
			if (_url.indexOf("?") >= 0) {
				_url += "&cachekill=" + new Date();
			}
			else {
				_url += "?cachekill=" + new Date();
			}
			
			var loader : URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, function(e : Event) {
				if (_onResponse != null) {
					_onResponse(JSON.parse(loader.data));
				}
			});
			
			loader.load(new URLRequest(_url));
		}
	}
}