class Core.KeyboardManager {
	
	var pressedKeys : Array = [];
	
	var onKeyPressed : Function;
	var onKeyReleased : Function;
	
	function KeyboardManager(_stage : Stage) {
		var self = this;
		var inputListener : Object = {};
		Key.addListener(inputListener);
		
		inputListener.onKeyDown = function() {
			if (pressedKeys.indexOf(Key.getCode()) < 0) {
				pressedKeys.push(Key.getCode());
			}
			
			if (self.onKeyPressed != null) {
				self.onKeyPressed(Key.getCode());
			}
		}
		
		inputListener.onKeyUp = function() {
			var pressedKeyIndex : Number = pressedKeys.indexOf(Key.getCode());
			if (pressedKeyIndex >= 0) {
				pressedKeys.splice(pressedKeyIndex, 1);
			}
			
			if (self.onKeyReleased != null) {
				self.onKeyReleased(Key.getCode());
			}
		}
	}
}