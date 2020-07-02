/**
* The following class assumes that each element has it's registration point at the top left corner and that 0,0 is the top position
*/

package Views {
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.display.Stage;
	
	public class ScrollableArea {
		
		var handle : DisplayObject;
		var mask : DisplayObject;
		var content : DisplayObject;
		
		var isVertical : Boolean;
		var progress : Number = 0;
		
		private var stage : Stage;
		private var mouseDragOffset : Point;
		private var isMouseDown : Boolean = false;
		
		function ScrollableArea(_handle : DisplayObject, _mask : DisplayObject, _content : DisplayObject, _isVertical : Boolean = true) {
			handle = _handle;
			mask = _mask;
			content = _content;
			isVertical = _isVertical;
			
			stage = handle.stage;
			
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onHandleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			handle.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		function onHandleMouseDown(e : MouseEvent) {
			mouseDragOffset = handle.parent.globalToLocal(new Point(e.stageX, e.stageY));
			mouseDragOffset.x -= handle.x;
			mouseDragOffset.y -= handle.y;
			
			isMouseDown = true;
		}
		
		function onStageMouseUp(e : MouseEvent) {
			isMouseDown = false;
		}
		
		function onEnterFrame(e : Event) {
			if (isVertical == true) {
				handle.height = mask.height * (mask.height / content.height);
				handle.height = Math.min(handle.height, mask.height);
				handle.y = getHandleYAtProgress();
			}
			
			if (isMouseDown == false) {
				return;
			}
			
			var mousePosition : Point = handle.parent.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			
			if (isVertical == false) {
				handle.x = mousePosition.x - mouseDragOffset.x;
			}
			if (isVertical == true) {
				handle.y = mousePosition.y - mouseDragOffset.y;
				handle.y = Math.max(handle.y, 0);
				handle.y = Math.min(handle.y, mask.height - handle.height);
				progress = handle.y / (mask.height - handle.height);
				content.y = -(content.height - mask.height) * progress;
			}
		}
		
		private function getHandleYAtProgress() {
			var range : Number = mask.height - handle.height;
			return range * progress;
		}
	}
}