package Core {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	
	public class KeyboardManager {
		
		public var pressedKeys : Array = [];
		
		public var onKeyPressed : Function;
		public var onKeyReleased : Function;
		
		function KeyboardManager(_child : MovieClip) {
			_child.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) {
				if (isKeyPressed(e.keyCode) == false) {
					pressedKeys.push(e.keyCode);
				}
				
				if (onKeyPressed != null) {
					onKeyPressed(e.keyCode);
				}
			});
			
			_child.stage.addEventListener(KeyboardEvent.KEY_UP, function(e : KeyboardEvent) {
				var pressedKeyIndex : int = pressedKeys.indexOf(e.keyCode);
				if (pressedKeyIndex >= 0) {
					pressedKeys.splice(pressedKeyIndex, 1);
				}
				
				if (onKeyReleased != null) {
					onKeyReleased(e.keyCode);
				}
			});
		}
		
		public function isKeyPressed(_keyCode : Number) : Boolean {
			return pressedKeys.indexOf(_keyCode) >= 0;
		}
	}
}