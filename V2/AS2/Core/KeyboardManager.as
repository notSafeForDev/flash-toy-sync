class Core.KeyboardManager {
	
	var pressedKeys : Array = [];
	
	var onKeyPressed : Function;
	var onKeyReleased : Function;
	
	function KeyboardManager(_child : MovieClip) {
		var self = this;
		var inputListener : Object = {};
		Key.addListener(inputListener);
		
		inputListener.onKeyDown = function() {
			if (self.isKeyPressed(Key.getCode()) == false) {
				self.pressedKeys.push(Key.getCode());
			}
			
			if (self.onKeyPressed != null) {
				self.onKeyPressed(Key.getCode());
			}
		}
		
		inputListener.onKeyUp = function() {
			var pressedKeyIndex : Number = self.getPressedKeyIndex(Key.getCode());
			if (pressedKeyIndex >= 0) {
				self.pressedKeys.splice(pressedKeyIndex, 1);
			}
			
			if (self.onKeyReleased != null) {
				self.onKeyReleased(Key.getCode());
			}
		}
	}
	
	function isKeyPressed(_keyCode : Number) : Boolean {
		return getPressedKeyIndex(_keyCode) >= 0;
	}
	
	private function getPressedKeyIndex(_keyCode : Number) : Number {
		for (var i : Number = 0; i < pressedKeys.length; i++) {
			if (pressedKeys[i] == _keyCode) {
				return i;
			}
		}
		
		return -1;
	}
}