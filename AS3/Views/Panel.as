package Views {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Stage;
	
	public class Panel {
		
		public var bounds : Rectangle;
		
		var container : MovieClip;
		var buttonMove : DisplayObject;
		var buttonMinimize : DisplayObject;
		
		private var stage : Stage;
		
		private var isMouseDown : Boolean = false;
		private var mouseDragOffset : Point;
		
		function Panel(_container : MovieClip, _buttonMove : DisplayObject, _buttonMinimize : DisplayObject) {
			container = _container;
			buttonMove = _buttonMove;
			buttonMinimize = _buttonMinimize;
			
			stage = container.stage;
			
			buttonMove.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMoveMouseDown);
			buttonMinimize.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMinimizeMouseDown);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		function onButtonMoveMouseDown(e : MouseEvent) {
			mouseDragOffset = container.parent.globalToLocal(new Point(e.stageX, e.stageY));
			mouseDragOffset.x -= container.x;
			mouseDragOffset.y -= container.y;
			
			isMouseDown = true;
		}
		
		function onButtonMinimizeMouseDown(e : MouseEvent) {
			container.play();
		}
		
		function onEnterFrame(e : Event) {
			if (isMouseDown == false) {
				return;
			}
			
			var mousePosition : Point = container.parent.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			
			container.x = mousePosition.x - mouseDragOffset.x;
			container.y = mousePosition.y - mouseDragOffset.y;
			
			if (bounds != null) {
				container.x = Math.max(container.x, bounds.x);
				container.x = Math.min(container.x, bounds.x + bounds.width);
				container.y = Math.max(container.y, bounds.y);
				container.y = Math.min(container.y, bounds.y + bounds.height);
			}
		}
		
		function onMouseUp(e : MouseEvent) {
			isMouseDown = false;
		}
	}
}