package Controllers {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	
	import Views.Panel;
	import Global.GlobalEvents;
	import Models.AnimationModel;
	
	public class PlayControlsPanelController {
		
		var buttonPlay : DisplayObject;
		var buttonStop : DisplayObject;
		var buttonStepForwards : DisplayObject;
		var buttonStepBackwards : DisplayObject;
		
		var textFirstFrame : TextField;
		var textCurrentFrame : TextField;
		var textLastFrame : TextField;
		
		function PlayControlsPanelController(_root : MovieClip, _panelContainer : MovieClip) {
			var panel : Panel = new Panel(_panelContainer, _panelContainer.ButtonMove, _panelContainer.ButtonMinimize);
			panel.bounds = new Rectangle(0, 0, 1280 - _panelContainer.width, 720 - 15);
			
			buttonPlay = _panelContainer.Content.ButtonPlay;
			buttonStop = _panelContainer.Content.ButtonStop;
			buttonStepForwards = _panelContainer.Content.ButtonStepForwards;
			buttonStepBackwards = _panelContainer.Content.ButtonStepBackwards;
			
			textFirstFrame = _panelContainer.Content.TextFirstFrame;
			textCurrentFrame = _panelContainer.Content.TextCurrentFrame;
			textLastFrame = _panelContainer.Content.TextLastFrame;
			
			showPlayButton(false);
			
			buttonPlay.addEventListener(MouseEvent.MOUSE_DOWN, onButtonPlayDown);
			buttonStop.addEventListener(MouseEvent.MOUSE_DOWN, onButtonStopDown);
			buttonStepForwards.addEventListener(MouseEvent.MOUSE_DOWN, onButtonStepForwardsDown);
			buttonStepBackwards.addEventListener(MouseEvent.MOUSE_DOWN, onButtonStepBackwardsDown);
			
			GlobalEvents.events.animation.frameUpdate.listen(onAnimationFrameUpdate);
			GlobalEvents.events.animation.forceStopped.listen(onAnimationForceStopped);
			GlobalEvents.events.animation.resumed.listen(onAnimationResumed);
		}
		
		function onAnimationFrameUpdate(e : Object) {
			textCurrentFrame.text = AnimationModel.childCurrentFrame.toString();
			
			if (AnimationModel.isChildFirstFrameInSectionDetermained == true) {
				textFirstFrame.text = AnimationModel.childFirstFrameInSection.toString();
			}
			else {
				textFirstFrame.text = "-";
			}
			
			if (AnimationModel.isChildLastFrameInSectionDetermained == true) {
				textLastFrame.text = AnimationModel.childLastFrameInSection.toString();
			}
			else {
				textLastFrame.text = "-";
			}
		}
		
		function onAnimationForceStopped(e : Object) {
			showPlayButton(true);
		}
		
		function onAnimationResumed(e : Object) {
			showPlayButton(false);
		}
		
		function onButtonPlayDown(e : MouseEvent) {
			GlobalEvents.events.playControlsPanel.play.emit();
		}
		
		function onButtonStopDown(e : MouseEvent) {
			GlobalEvents.events.playControlsPanel.stop.emit();
		}
		
		function onButtonStepForwardsDown(e : MouseEvent) {
			GlobalEvents.events.playControlsPanel.stepForwards.emit();
		}
		
		function onButtonStepBackwardsDown(e : MouseEvent) {
			GlobalEvents.events.playControlsPanel.stepBackwards.emit();
		}
		
		function showPlayButton(_state : Boolean) {
			buttonPlay.visible = _state;
			buttonStop.visible = !_state;
		}
	}
}