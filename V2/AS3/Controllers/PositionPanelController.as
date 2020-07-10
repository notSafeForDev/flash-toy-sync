package Controllers {
	
	import flash.display.MovieClip;
	
	import Core.*;
	
	import Models.SyncModel;
	
	import Global.GlobalEvents;

	public class PositionPanelController {
		
		var slider : UISlider;
		
		var markerBefore : MovieClip;
		
		function PositionPanelController(_panelContainer : MovieClip) {
			markerBefore = _panelContainer.Content.MarkerBefore;
			MovieClipUtil.setVisible(markerBefore, false);
			
			new UIDragableWindow(_panelContainer, _panelContainer.ButtonMove);
			slider = new UISlider(_panelContainer.Content.Rod, _panelContainer.Content.Marker, false);
			
			slider.onStartDrag = FunctionUtil.bind(this, onRodStartDrag);
			slider.onDragging = FunctionUtil.bind(this, onRodDragging);
			slider.onStopDrag = FunctionUtil.bind(this, onRodStopDrag);
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.frame.update.listen(this, onFrameUpdate);
		}
		
		function onFrameUpdate(e : Object) {
			if (SyncModel.animation == null) {
				return;
			}
			
			slider.value = 1 - (SyncModel.getInterpolatedPosition()) * 0.01;
			MovieClipUtil.setAlpha(slider.handle, SyncModel.hasPositionOnFrame() ? 1 : 0.5);
		}
		
		function onRodStartDrag(_value : Number) {
			MovieClipUtil.setVisible(markerBefore, true);
			MovieClipUtil.setY(markerBefore, MovieClipUtil.getY(slider.handle));
			GlobalEvents.events.positionPanel.marked.emit({position: getPositionFromSlider()});
		}
		
		function onRodDragging(_value : Number) {
			GlobalEvents.events.positionPanel.marked.emit({position: getPositionFromSlider()});
		}
		
		function onRodStopDrag(_value : Number) {
			MovieClipUtil.setVisible(markerBefore, false);
			GlobalEvents.events.positionPanel.marked.emit({position: getPositionFromSlider()});
		}
		
		function getPositionFromSlider() {
			return Math.floor((1 - slider.value) * 100);
		}
	}
}