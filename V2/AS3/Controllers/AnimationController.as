package Controllers {
	
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	
	import Core.*;
	
	import Models.AnimationModel;
	
	import Global.GlobalEvents;
	
	public class AnimationController {
		
		var animationContainer : MovieClip;
		
		var keyboardManager : KeyboardManager;
		
		var swfLoader : SWFLoader;
		var fileName : String;
		
		var lastPlayedFrame : Number = -1;
		
		function AnimationController(_animationContainer : MovieClip) {
			animationContainer = _animationContainer;
			
			keyboardManager = new KeyboardManager(animationContainer.root);
			keyboardManager.onKeyPressed = onKeyPressed;
			
			swfLoader = new SWFLoader();
			
			browseSWF(function(_fileName : String) {
				fileName = _fileName;
				var name : String = _fileName.substr(0, _fileName.lastIndexOf(".swf"));
				loadAnimationData("Animations/" + name + ".json", function(_data : Object) {
					onAnimationDataLoaded(_data);
				});
			});
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.syncData.loaded.listen(onSyncDataLoaded);
			GlobalEvents.events.hierarchyPanel.childSelected.listen(onHierarchyPanelChildSelected);
			GlobalEvents.events.playControlsPanel.play.listen(onPlayControlsPanelPlay);
			GlobalEvents.events.playControlsPanel.stop.listen(onPlayControlsPanelStop);
			GlobalEvents.events.playControlsPanel.stepBackwards.listen(onPlayControlsPanelStepBackwards);
			GlobalEvents.events.playControlsPanel.stepForwards.listen(onPlayControlsPanelStepForwards);
			GlobalEvents.events.frame.update.listen(onFrameUpdate);
		}
		
		function onSyncDataLoaded(e : Object) {
			loadSWF("Animations/" + fileName, onAnimationLoaded);
		}
		
		function onKeyPressed(_key : Number) {
			var isShiftKeyPressed : Boolean = keyboardManager.pressedKeys.indexOf(Keyboard.SHIFT) >= 0;
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected);
			
			if (_key == Keyboard.LEFT || _key == Keyboard.A) {
				if (isShiftKeyPressed == true && AnimationModel.isChildFirstFrameInLoopDetermained == true) {
					stopOnFrame(AnimationModel.childFirstFrameInLoop);
				}
				else {
					stopOnFrame(currentFrame - 1);
				}
			}
			if (_key == Keyboard.RIGHT || _key == Keyboard.D) {
				if (isShiftKeyPressed == true && AnimationModel.isChildLastFrameInLoopDetermained == true) {
					stopOnFrame(AnimationModel.childLastFrameInLoop);
				}
				else {
					stopOnFrame(currentFrame + 1);
				}
			}
		}
		
		function onAnimationDataLoaded(_data : Object) {
			AnimationModel.sourceWidth = _data.width;
			AnimationModel.sourceHeight = _data.height;
			
			GlobalEvents.events.animationData.loaded.emit({data: _data});
		}
		
		function onAnimationLoaded(_animation : MovieClip) {
			AnimationModel.animation = _animation;
			AnimationModel.childSelected = _animation;
			
			lastPlayedFrame = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected);
			
			fitAnimationOnScreen(_animation, AnimationModel.sourceWidth, AnimationModel.sourceHeight);
			
			GlobalEvents.events.animation.loaded.emit();
		}
		
		function onHierarchyPanelChildSelected(e : Object) {
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(e.child);
			
			AnimationModel.childSelected = e.child;
			AnimationModel.childFirstFrameInLoop = currentFrame;
			AnimationModel.childLastFrameInLoop = currentFrame;
			AnimationModel.isChildFirstFrameInLoopDetermained = false;
			AnimationModel.isChildLastFrameInLoopDetermained = false;
			
			lastPlayedFrame = currentFrame;
		}
		
		function onPlayControlsPanelPlay(e : Object) {
			AnimationModel.childSelected.play();
			AnimationModel.isChildForceStopped = false;
			GlobalEvents.events.animation.resumed.emit();
		}
		
		function onPlayControlsPanelStop(e : Object) {
			AnimationModel.childSelected.stop();
			AnimationModel.isChildForceStopped = true;
			GlobalEvents.events.animation.forceStopped.emit();
		}
		
		function onPlayControlsPanelStepBackwards(e : Object) {
			stopOnFrame(MovieClipUtil.getCurrentFrame(AnimationModel.childSelected) - 1);
		}
		
		function onPlayControlsPanelStepForwards(e : Object) {
			stopOnFrame(MovieClipUtil.getCurrentFrame(AnimationModel.childSelected) + 1);
		}
		
		function onFrameUpdate(e : Object) {
			if (AnimationModel.childSelected == null) {
				return;
			}
			
			if (AnimationModel.isChildForceStopped == true) {
				AnimationModel.childSelected.stop();
				lastPlayedFrame = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected);
				return;
			}
			
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected);
			
			if (currentFrame != lastPlayedFrame && currentFrame != lastPlayedFrame + 1) {
				AnimationModel.childFirstFrameInLoop = currentFrame;
				AnimationModel.isChildFirstFrameInLoopDetermained = true;
				AnimationModel.isChildLastFrameInLoopDetermained = false;
			}
			
			if (currentFrame >= AnimationModel.childLastFrameInLoop) {
				AnimationModel.childLastFrameInLoop = currentFrame;
			}
			else if (AnimationModel.isChildFirstFrameInLoopDetermained == true) {
				AnimationModel.isChildLastFrameInLoopDetermained = true;
			}
			
			lastPlayedFrame = currentFrame;
		}
		
		function stopOnFrame(_frame : Number) {
			AnimationModel.childSelected.gotoAndStop(_frame);
			AnimationModel.isChildForceStopped = true;
			
			if (AnimationModel.isChildLastFrameInLoopDetermained == false) {
				AnimationModel.childLastFrameInLoop = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected);
			}
			
			GlobalEvents.events.animation.forceStopped.emit();
		}
		
		function browseSWF(_onSelected : Function) {
			swfLoader.browse(_onSelected);
		}
		
		function loadAnimationData(_path : String, _onLoaded : Function) {
			JSONLoader.load(_path, _onLoaded);
		}
		
		function loadSWF(_path : String, _onLoaded : Function) {
			swfLoader.load(_path, animationContainer, _onLoaded);
		}
		
		function fitAnimationOnScreen(_animation : MovieClip, _sourceWidth : Number, _sourceHeight : Number) {
			var maxScaleX : Number = (StageUtil.getWidth(_animation) / _sourceWidth);
			var maxScaleY : Number = (StageUtil.getHeight(_animation) / _sourceHeight);
			
			var scale : Number = Math.min(maxScaleX, maxScaleY);
			
			var offsetX : Number = (StageUtil.getWidth(_animation) - (_sourceWidth * scale)) / 2;
			var offsetY : Number = (StageUtil.getHeight(_animation) - (_sourceHeight * scale)) / 2;
			
			MovieClipUtil.setX(_animation, offsetX);
			MovieClipUtil.setY(_animation, offsetY);
			MovieClipUtil.setScaleX(_animation, scale);
			MovieClipUtil.setScaleY(_animation, scale);
		}
	}
}