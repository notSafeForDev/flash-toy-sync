package Controllers {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import Views.Panel;
	import Global.GlobalEvents;
	import Models.SyncModel;
	import Models.AnimationModel;

	public class PositionIndicatorPanelController {
		
		var rod : DisplayObject;
		var marker : MovieClip;
		var markerBefore : MovieClip;
		
		var stage : Stage;
		
		var isMouseOver : Boolean = false;
		var isMouseDown : Boolean = false;
		
		function PositionIndicatorPanelController(_root : MovieClip, _panelContainer : MovieClip) {
			var panel : Panel = new Panel(_panelContainer, _panelContainer.ButtonMove, _panelContainer.ButtonMinimize);
			panel.bounds = new Rectangle(0, 0, 1280 - _panelContainer.width, 720 - 15);
			
			rod = _panelContainer.Content.Rod;
			marker = _panelContainer.Content.Marker;
			markerBefore = _panelContainer.Content.MarkerBefore;
			
			marker.mouseEnabled = false;
			markerBefore.mouseEnabled = false;
			markerBefore.visible = false;
			
			stage = rod.stage;
			
			rod.addEventListener(MouseEvent.MOUSE_OVER, onRodMouseOver);
			rod.addEventListener(MouseEvent.MOUSE_OUT, onRodMouseOut);
			rod.addEventListener(MouseEvent.MOUSE_DOWN, onRodMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		function onRodMouseOver(e : MouseEvent) {
			isMouseOver = true;
			markerBefore.y = marker.y;
			markerBefore.visible = true;
		}
		
		function onRodMouseOut(e : MouseEvent) {
			isMouseOver = false;
			if (isMouseDown == false) {
				markerBefore.visible = false;
			}
		}
		
		function onRodMouseDown(e : MouseEvent) {
			isMouseDown = true;
			moveMarkerToMouse();
			GlobalEvents.events.positionIndicatorPanel.marked.emit({
				position: getPositionForMarkerY(marker.y)
			});
		}
		
		function onMouseUp(e : MouseEvent) {
			isMouseDown = false;
			markerBefore.visible = false;
		}
		
		function onEnterFrame(e : Event) {
			marker.y = getMarkerYForPosition(SyncModel.getInterpolatedPositionOnFrame(AnimationModel.childCurrentFrame));
			marker.alpha = SyncModel.hasPositionOnFrame(AnimationModel.childCurrentFrame) == true ? 1 : 0.5;
			
			if (isMouseOver == false && isMouseDown == false) {
				return;
			}
			
			moveMarkerToMouse();
			
			if (isMouseDown == true) {
				GlobalEvents.events.positionIndicatorPanel.marked.emit({
					position: getPositionForMarkerY(marker.y)
				});
			}
		}
		
		function moveMarkerToMouse() {
			var mousePosition : Point = rod.parent.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			marker.y = mousePosition.y;
			marker.y = Math.max(marker.y, 20);
			marker.y = Math.min(marker.y, 110);
		}
		
		function getMarkerYForPosition(_position : Number) {
			return 110 - _position * (90 / 100);
		}
		
		function getPositionForMarkerY(_markerY : Number) {
			return 100 - (marker.y - 20) * (100 / 90);
		}
	}
}