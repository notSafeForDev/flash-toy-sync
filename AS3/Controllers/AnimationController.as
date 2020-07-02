package Controllers {
	
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import Global.GlobalEvents;
	import Views.Panel;
	import Models.AnimationModel;
	import Models.UserConfigModel;
	import Components.JSONLoader;
	
	public class AnimationController {
		
		var animation : MovieClip;
		var animationData : Object;
		var root : MovieClip;
		var childSelected : MovieClip;
		var lastFrame : Number = -1;
		
		function AnimationController(_root : MovieClip) {
			root = _root;
			
			browseAnimationData(function(data : Object) {
				animationData = data;
				AnimationModel.fps = animationData.fps;
				AnimationModel.width = animationData.width;
				AnimationModel.height = animationData.height;
				GlobalEvents.events.animationData.loaded.emit({data: data});
			});
			
			addGlobalEventListeners();
		}
		
		function browseAnimationData(_onLoaded : Function) {
			JSONLoader.browse(_onLoaded);
		}
		
		function loadAnimation(_fileName : String) {
			var loader : Loader = new Loader();
			var url : URLRequest = new URLRequest("Animations/" + _fileName);
			root.addChildAt(loader, 0);
			
			function onLoaderComplete(e : Event) {
				animation = MovieClip(loader.content);
				
				resizeAnimation();
				
				childSelected = animation;
				
				AnimationModel.animation = animation;
				AnimationModel.childSelected = childSelected;
				AnimationModel.currentFrame = animation.currentFrame;
				AnimationModel.childCurrentFrame = childSelected.currentFrame;
				
				GlobalEvents.events.animation.loaded.emit({animation: animation});
				animation.addEventListener(Event.EXIT_FRAME, onAnimationExitFrame);
				
				addKeyboardEventListeners();
			}
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load(url);
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.syncData.loaded.listen(function() {
				loadAnimation(animationData.swf);
			});
			
			GlobalEvents.events.sync.childSelected.listen(function(e : Object) {
				if (childSelected != null && AnimationModel.isForceStopped == true) {
					childSelected.play();
				}
																	
				childSelected = e.child;
				AnimationModel.childSelected = childSelected;
				AnimationModel.isForceStopped = false;
				AnimationModel.childCurrentFrame = childSelected.currentFrame;
				AnimationModel.childFirstFrameInSection = childSelected.currentFrame;
				AnimationModel.childLastFrameInSection = childSelected.currentFrame;
				AnimationModel.isChildFirstFrameInSectionDetermained = false;
				AnimationModel.isChildLastFrameInSectionDetermained = false;
				lastFrame = childSelected.currentFrame;
				GlobalEvents.events.animation.resumed.emit();
			});
			
			GlobalEvents.events.playControlsPanel.play.listen(function() {
				childSelected.play();
				AnimationModel.isForceStopped = false;
				GlobalEvents.events.animation.resumed.emit();
			});
			
			GlobalEvents.events.playControlsPanel.stop.listen(function() {
				childSelected.stop();
				AnimationModel.isForceStopped = true;
				GlobalEvents.events.animation.forceStopped.emit();
			});
			
			GlobalEvents.events.playControlsPanel.stepBackwards.listen(function() {
				stepFrame(-1);
			});
			
			GlobalEvents.events.playControlsPanel.stepForwards.listen(function() {
				stepFrame(1);
			});
		}
		
		function addKeyboardEventListeners() {
			if (UserConfigModel.showEditor == false) {
				return;
			}
			
			animation.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) {
				if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
					if (e.shiftKey == true && AnimationModel.isChildFirstFrameInSectionDetermained == true) {
						stopOnFrame(AnimationModel.childFirstFrameInSection);
					}
					else {
						stepFrame(-1);
					}
				}
				if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
					if (e.shiftKey == true && AnimationModel.isChildLastFrameInSectionDetermained == true) {
						stopOnFrame(AnimationModel.childLastFrameInSection);
					}
					else {
						stepFrame(1);
					}
				}
			});
		}
		
		function onAnimationExitFrame(e : Event) {
			AnimationModel.currentFrame = animation.currentFrame;
			AnimationModel.childCurrentFrame = childSelected.currentFrame;
			
			if (AnimationModel.isForceStopped == true) {
				childSelected.stop();
				lastFrame = childSelected.currentFrame;
				if (AnimationModel.isChildLastFrameInSectionDetermained == false) {
					// Prevents it from determaining the last frame, if the user force stops, goes back and then resumes
					AnimationModel.childLastFrameInSection = AnimationModel.childFirstFrameInSection;
				}
				GlobalEvents.events.animation.frameUpdate.emit();
				return;
			}
			
			var didChangeMoreThanOneFrame : Boolean = childSelected.currentFrame < lastFrame - 1 || childSelected.currentFrame > lastFrame + 1;
			if (didChangeMoreThanOneFrame == true && childSelected.currentFrame != AnimationModel.childFirstFrameInSection) {
				AnimationModel.childFirstFrameInSection = childSelected.currentFrame;
				AnimationModel.childLastFrameInSection = childSelected.currentFrame;
				AnimationModel.isChildFirstFrameInSectionDetermained = true;
				AnimationModel.isChildLastFrameInSectionDetermained = false;
			}
			
			if (childSelected.currentFrame >= AnimationModel.childLastFrameInSection) {
				AnimationModel.childLastFrameInSection = childSelected.currentFrame;
			} 
			else {
				AnimationModel.isChildLastFrameInSectionDetermained = true;
			}
			
			lastFrame = childSelected.currentFrame;
			
			GlobalEvents.events.animation.frameUpdate.emit();
		}
		
		function stopOnFrame(_frame : Number) {
			childSelected.gotoAndStop(_frame);
			AnimationModel.isForceStopped = true;
			GlobalEvents.events.animation.forceStopped.emit();
		}
		
		function stepFrame(_direction : Number) {
			stopOnFrame(childSelected.currentFrame + _direction);
		}
		
		function resizeAnimation() {
			var maxScaleX : Number = (root.stage.stageWidth / animationData.width);
			var maxScaleY : Number = (root.stage.stageHeight / animationData.height);
			
			var scale : Number = Math.min(maxScaleX, maxScaleY);
			
			var offsetX : Number = (root.stage.stageWidth - (animationData.width * scale)) / 2;
			var offsetY : Number = (root.stage.stageHeight - (animationData.height * scale)) / 2;
			
			animation.x = offsetX;
			animation.y = offsetY;
			animation.scaleX = scale;
			animation.scaleY = scale;
		}
	}
}