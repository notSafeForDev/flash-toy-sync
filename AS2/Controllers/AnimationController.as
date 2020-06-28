import Global.GlobalEvents;
import Components.JSONLoader;

import Models.AnimationModel;
import Models.UserConfigModel;

class Controllers.AnimationController {

	var animationsPath : String = "Animations/";
	
	var animationContainer : MovieClip;
	var animationData : Object;
	var animationLoaded : Boolean = false;
	
	var steppedFromFrame : Number = -1;
	var steppedToFrame : Number = -1;
	var lastPlayedFrame : Number = -1;
	
	function AnimationController(_animationContainer : MovieClip) {
		var self = this;
		
		animationContainer = _animationContainer;
		
		GlobalEvents.events.userConfig.loaded.listen(function(e : Object) {
			self.onUserConfigLoaded(e);
		});
		GlobalEvents.events.syncData.loaded.listen(function(e : Object) {
			self.onSyncDataLoaded(e);
		});
		GlobalEvents.events.frame.update.listen(function() {
			self.onFrameUpdate();
		});
		
		GlobalEvents.events.index.frameChange.listen(function(e : Object) {
			self.animationContainer.gotoAndPlay(e.frame);
		});
		
		GlobalEvents.events.controlPanel.play.listen(function() {
			AnimationModel.isForceStopped = false;
			self.animationContainer.play();
			GlobalEvents.events.animation.resumed.emit();
		});
		GlobalEvents.events.controlPanel.stop.listen(function() {
			AnimationModel.isForceStopped = true;
			self.animationContainer.stop();
			GlobalEvents.events.animation.forceStopped.emit();
		});
		GlobalEvents.events.controlPanel.stepBackwards.listen(function() {
			self.stopOnFrame(self.animationContainer._currentframe - 1);
		});
		GlobalEvents.events.controlPanel.stepForwards.listen(function() {
			self.stopOnFrame(self.animationContainer._currentframe + 1);
		});
	}
	
	function onUserConfigLoaded(e : Object) {		
		var self = this;
		JSONLoader.browse("Animations/", function(_json : Object) {
			self.onAnimationJSONLoaded(_json);
		});
	}
	
	function onAnimationJSONLoaded(_json : Object) {
		var self = this;
		
		animationData = _json;
		
		AnimationModel.fps = animationData.fps;
		AnimationModel.startFrame = animationData.startFrame;
		AnimationModel.modifiers = animationData.modifiers;
		
		GlobalEvents.events.animationData.loaded.emit({
			animationData: animationData
		});
	}
	
	function onSyncDataLoaded() {
		var self = this;
		
		var animationLoaderListener : Object = {};
		var animationLoader : MovieClipLoader = new MovieClipLoader();
		animationLoader.addListener(animationLoaderListener);
		
		animationLoaderListener.onLoadInit = function() {
			self.onAnimationLoaded();
		}
		
		animationLoader.loadClip(animationsPath + animationData.swf, animationContainer);
	}
	
	function onAnimationLoaded() {
		var self = this;
		
		resizeAnimation();
		
		GlobalEvents.events.animation.loaded.emit({animation: animationContainer});
		
		animationLoaded = true;
		
		if (UserConfigModel.editorEnabled == true) {
			addEditorKeyboardInputListeners();
		}
	}
	
	function addEditorKeyboardInputListeners() {
		var self = this;
		
		GlobalEvents.events.keyboard.left.listen(function(e : Object) {
			if (e.modifierKey == Key.SHIFT) {
				self.stopOnFrame(AnimationModel.sectionStartFrame);
			}
			else {
				self.stopOnFrame(self.animationContainer._currentframe - 1);
			}
		});
		GlobalEvents.events.keyboard.right.listen(function(e : Object) {
			if (e.modifierKey == Key.SHIFT) {
				self.stopOnFrame(AnimationModel.sectionLastFrame);
			}
			else {
				self.stopOnFrame(self.animationContainer._currentframe + 1);
			}
		});
	}
	
	function onFrameUpdate() {
		if (animationLoaded == false) {
			return;
		}
		
		if (AnimationModel.isForceStopped == true) {
			animationContainer.stop();
		}
		
		var frame : Number;
		
		// This applies to situations where the user steps forwards to a frame with code which changes the frame
		if (steppedToFrame != -1 && steppedToFrame != animationContainer._currentframe) {
			animationContainer.prevFrame();
			frame = animationContainer._currentframe - 1;
		} else {
			frame = animationContainer._currentframe;
		}
		
		if (AnimationModel.isForceStopped == false) {
			var didMoveMoreThanOneFrame : Boolean = frame > lastPlayedFrame + 1 || frame < lastPlayedFrame - 1;
		
			if (didMoveMoreThanOneFrame == true && frame != AnimationModel.sectionStartFrame) {
				AnimationModel.sectionStartFrame = frame;
				AnimationModel.sectionLastFrame = frame;
			}
			
			if (frame > AnimationModel.sectionLastFrame) {
				AnimationModel.sectionLastFrame = frame;
			}
		}
		
		lastPlayedFrame = frame;
		steppedFromFrame = -1;
		steppedToFrame = -1;
		
		AnimationModel.currentFrame = frame;
		
		GlobalEvents.events.animation.frameUpdate.emit({frame: frame});
	}
	
	function stopOnFrame(_frame : Number) {
		AnimationModel.isForceStopped = true;
		steppedToFrame = _frame;
		animationContainer.gotoAndStop(_frame);
		GlobalEvents.events.animation.forceStopped.emit();
	}
	
	function resizeAnimation() {
		var maxScaleX : Number = (Stage.width / animationData.size.width) * 100;
		var maxScaleY : Number = (Stage.height / animationData.size.height) * 100;
		var scale : Number = Math.min(maxScaleX, maxScaleY);
		
		var offsetX : Number = (Stage.width - animationData.size.width * (scale / 100)) / 2;
		var offsetY : Number = (Stage.height - animationData.size.height * (scale / 100)) / 2;
		
		animationContainer._x = offsetX;
		animationContainer._y = offsetY;
		animationContainer._xscale = scale;
		animationContainer._yscale = scale;
	}
}