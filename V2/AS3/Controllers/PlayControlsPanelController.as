package Controllers {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import Core.*;

	import Models.AnimationModel;

	import Global.GlobalEvents;

	public class PlayControlsPanelController {
		
		var buttonPlay : UIButton;
		var buttonStop : UIButton;
		var buttonStepBackwards : UIButton;
		var buttonStepForwards : UIButton;
		
		var textFirstFrame : TextField;
		var textCurrentFrame : TextField;
		var textLastFrame : TextField;
		
		function PlayControlsPanelController(_panelContainer : MovieClip) {
			buttonPlay = new UIButton(_panelContainer.Content.ButtonPlay);
			buttonStop = new UIButton(_panelContainer.Content.ButtonStop);
			buttonStepBackwards = new UIButton(_panelContainer.Content.ButtonStepBackwards);
			buttonStepForwards = new UIButton(_panelContainer.Content.ButtonStepForwards);
			
			textFirstFrame = _panelContainer.Content.TextFirstFrame;
			textCurrentFrame = _panelContainer.Content.TextCurrentFrame;
			textLastFrame = _panelContainer.Content.TextLastFrame;
			
			buttonPlay.onMouseDown = onButtonPlayMouseDown;
			buttonStop.onMouseDown = onButtonStopMouseDown;
			buttonStepBackwards.onMouseDown = onButtonStepBackwardsMouseDown;
			buttonStepForwards.onMouseDown = onButtonStepForwardsMouseDown;
			
			showPlayButton(false);
			
			new UIDragableWindow(_panelContainer, _panelContainer.ButtonMove);
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.frame.update.listen(onFrameUpdate);
		}
		
		function onFrameUpdate(e : Object) {
			if (AnimationModel.childSelected == null) {
				return;
			}
			
			if (AnimationModel.isChildFirstFrameInLoopDetermained == true) {
				textFirstFrame.text = AnimationModel.childFirstFrameInLoop.toString();
			}
			else {
				textFirstFrame.text = "-";
			}
			
			textCurrentFrame.text = MovieClipUtil.getCurrentFrame(AnimationModel.childSelected).toString();
			
			if (AnimationModel.isChildLastFrameInLoopDetermained == true) {
				textLastFrame.text = AnimationModel.childLastFrameInLoop.toString();
			}
			else {
				textLastFrame.text = "-";
			}
		}
		
		function onButtonPlayMouseDown() {
			GlobalEvents.events.playControlsPanel.play.emit();
			showPlayButton(false);
		}
		
		function onButtonStopMouseDown() {
			GlobalEvents.events.playControlsPanel.stop.emit();
			showPlayButton(true);
		}
		
		function onButtonStepBackwardsMouseDown() {
			GlobalEvents.events.playControlsPanel.stepBackwards.emit();
			showPlayButton(true);
		}
		
		function onButtonStepForwardsMouseDown() {
			GlobalEvents.events.playControlsPanel.stepForwards.emit();
			showPlayButton(true);
		}
		
		function showPlayButton(_state : Boolean) {
			// MovieClipUtil.setVisible doesn't work for AS3 as element is a DisplayObject
			try {
				buttonPlay.element["_visible"] = _state;
				buttonStop.element["_visible"] = !_state;
			}
			catch (error) {
				buttonPlay.element.visible = _state;
				buttonStop.element.visible = !_state;
			}
		}
	}
}