package Core {
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	
	public class KeyboardManager {
		
		public var pressedKeys : Array = [];
		
		public var onKeyPressed : Function;
		public var onKeyReleased : Function;
		
		function KeyboardManager(_root : DisplayObject) {
			_root.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) {
				if (pressedKeys.indexOf(e.keyCode) < 0) {
					pressedKeys.push(e.keyCode);
				}
				
				if (onKeyPressed != null) {
					onKeyPressed(e.keyCode);
				}
			});
			
			_root.addEventListener(KeyboardEvent.KEY_UP, function(e : KeyboardEvent) {
				var pressedKeyIndex : int = pressedKeys.indexOf(e.keyCode);
				if (pressedKeyIndex >= 0) {
					pressedKeys.splice(pressedKeyIndex, 1);
				}
				
				if (onKeyReleased != null) {
					onKeyReleased(e.keyCode);
				}
			});
		}
	}
}