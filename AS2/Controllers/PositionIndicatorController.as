import Global.GlobalEvents;
import Components.JSON;
import Utils.ObjectUtil;

import Models.SyncModel;
import Models.AnimationModel;
import Models.UserConfigModel;

class Controllers.PositionIndicatorController {
	
	var positionIndicator : MovieClip;
	
	var isMouseOver : Boolean = false;
	var isMouseDown : Boolean = false;
	
	function PositionIndicatorController(_positionIndicator : MovieClip) {
		positionIndicator = _positionIndicator;
		
		addGlobalEventListeners();
		addMouseEventListeners();
	}
	
	function addGlobalEventListeners() {
		var self = this;
		
		GlobalEvents.events.animation.loaded.listen(function() {
			if (UserConfigModel.editorEnabled == true) {
				self.addKeyboardEventListeners();
			}
		});
		
		GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
			self.onAnimationFrameUpdate(e);
		});
	}
	
	function addMouseEventListeners() {
		var self = this;
		
		positionIndicator.Rod.onPress = function() {
			self.isMouseDown = true;
		}
		
		positionIndicator.Rod.onRelease = function() {
			self.isMouseDown = false;
			self.moveMarkerToMouse();
			self.markPosition(self.getPositionAtY(self.positionIndicator.Marker._y));
		}
		
		positionIndicator.Rod.onRollOver = function() {
			self.isMouseOver = true;
			
			if (SyncModel.hasPositionOnFrame(AnimationModel.currentFrame) == false) {
				self.moveMarkerToMouse();
			}
		}
		
		positionIndicator.Rod.onRollOut = function() {
			self.isMouseDown = false;
			self.isMouseOver = false;
		}
		
		positionIndicator.onMouseMove = function() {
			if (self.isMouseOver == false) {
				return;
			}
			
			if (self.isMouseDown == true || SyncModel.hasPositionOnFrame(AnimationModel.currentFrame) == false) {
				self.moveMarkerToMouse();
			}
		}
	}
	
	function addKeyboardEventListeners() {
		var self = this;
		
		GlobalEvents.events.keyboard.up.listen(function(e : Object) {
			var position : Number = SyncModel.getInterpolatedPositionAtFrame(AnimationModel.currentFrame);
			
			if (position < 0) {
				self.markPosition(100);
			}
			else {
				self.markPosition(position + 10);
			}
		});
		
		GlobalEvents.events.keyboard.down.listen(function(e : Object) {
			var position : Number = SyncModel.getInterpolatedPositionAtFrame(AnimationModel.currentFrame);
			
			if (position < 0) {
				self.markPosition(100);
			}
			else {
				self.markPosition(position - 10);
			}
		});
		
		GlobalEvents.events.keyboard.remove.listen(function(e : Object) {
			SyncModel.removePositionAtFrame(AnimationModel.currentFrame);
		});
	}
	
	function onAnimationFrameUpdate(e : Object) {
		if (isMouseOver == true) {
			return;
		}
		
		var hasPositionOnFrame : Boolean = SyncModel.hasPositionOnFrame(AnimationModel.currentFrame);
		var position : Number = SyncModel.getInterpolatedPositionAtFrame(AnimationModel.currentFrame);
		
		if (hasPositionOnFrame == true) {
			positionIndicator.Marker._alpha = 100;
		} 
		else {
			positionIndicator.Marker._alpha = 50;
		}
		
		if (position >= 0) {
			positionIndicator.Marker._y = getYAtPosition(position);
		} 
		else {
			positionIndicator.Marker._y = getYAtPosition(100);
		}
	}
	
	function markPosition(position : Number) {
		GlobalEvents.events.positionIndicator.marked.emit({position: position});
	}
	
	function moveMarkerToMouse() {
		positionIndicator.Marker._y = positionIndicator._ymouse;
		positionIndicator.Marker._y = Math.max(positionIndicator.Marker._y, -45);
		positionIndicator.Marker._y = Math.min(positionIndicator.Marker._y, 45);
	}
	
	function getPositionAtY(_markerY : Number) : Number {
		return Math.floor(100 - (_markerY + 45) * (100 / 90));
	}
	
	function getYAtPosition(_position : Number) : Number {
		return Math.floor(45 - _position * (90 / 100));
	}
}