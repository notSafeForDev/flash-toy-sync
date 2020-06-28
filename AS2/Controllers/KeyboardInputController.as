import Global.GlobalEvents;

class Controllers.KeyboardInputController {
	
	function KeyboardInputController() {
		var inputListener : Object = {};
		Key.addListener(inputListener);
		
		inputListener.onKeyDown = function() {
			var keyA : Number = 65;
			var keyD : Number = 68;
			var keyW : Number = 87;
			var keyS : Number = 83;
			var keyMinus : Number = 109;
			
			var isLeftKeyDown : Boolean = Key.isDown(Key.LEFT) == true || Key.isDown(keyA);
			var isRightKeyDown : Boolean = Key.isDown(Key.RIGHT) == true || Key.isDown(keyD);
			var isUpKeyDown : Boolean = Key.isDown(Key.UP) == true || Key.isDown(keyW);
			var isDownKeyDown : Boolean = Key.isDown(Key.DOWN) == true || Key.isDown(keyS);
			var isPlayKeyDown : Boolean = Key.isDown(Key.SPACE) == true || Key.isDown(Key.ENTER);
			var isRemoveKeyDown : Boolean = Key.isDown(keyMinus) == true;
			
			var modifierKey : Number = -1;
			if (Key.isDown(Key.SHIFT) == true) {
				modifierKey = Key.SHIFT;
			}
			else if (Key.isDown(Key.CONTROL) == true) {
				modifierKey = Key.CONTROL;
			}
			
			if (isLeftKeyDown == true) {
				GlobalEvents.events.keyboard.left.emit({modifierKey: modifierKey});
			}
			if (isRightKeyDown == true) {
				GlobalEvents.events.keyboard.right.emit({modifierKey: modifierKey});
			}
			if (isUpKeyDown == true) {
				GlobalEvents.events.keyboard.up.emit({modifierKey: modifierKey});
			}
			if (isDownKeyDown == true) {
				GlobalEvents.events.keyboard.down.emit({modifierKey: modifierKey});
			}
			if (isPlayKeyDown == true) {
				GlobalEvents.events.keyboard.play.emit({modifierKey: modifierKey});
			}
			if (isRemoveKeyDown == true) {
				GlobalEvents.events.keyboard.remove.emit({modifierKey: modifierKey});
			}
		}
	}
}