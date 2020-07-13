package Types {
	
	import flash.display.MovieClip;
	
	import Core.MathUtil;
	import Types.SyncPosition;
	
	public class SyncSection {
		
		public var childPath : Array;
		public var activeWhile : Object;
		public var firstFrame : Number = -1;
		public var lastFrame : Number = -1;
		public var framesDelta : Number = 0;
		public var positions : Array;
		
		function SyncSection(_childPath : Array) {
			childPath = _childPath;
			
			// In AS2, Mutable variables should not be assigned above the constructor, as the original values get shared across all instances
			positions = [];
			activeWhile = {};
		}
		
		public function isFrameWithinSection(_frame : Number) : Boolean {
			return _frame >= firstFrame && _frame <= lastFrame;
		}
		
		public function mergeWithSection(_section : SyncSection) {
			for (var i : Number = 0; i < _section.positions.length; i++) {
				setPosition(_section.positions[i].frame, _section.positions[i].position);
			}
		}
		
		public function setPosition(_frame : Number, _position : Number) {
			var index : Number = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				positions[index].position = _position;
			}
			else {
				positions.push(new SyncPosition(_frame, _position));
			}
			
			sortPositions();
			firstFrame = positions[0].frame;
			lastFrame = positions[positions.length - 1].frame;
			framesDelta = lastFrame - firstFrame + 1;
		}
		
		public function removePosition(_frame : Number) {
			var index : Number = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				positions.splice(index, 1);
			}
			
			if (positions.length > 0) {
				firstFrame = positions[0].frame;
				lastFrame = positions[positions.length - 1].frame;
			} 
			else {
				firstFrame = -1;
				lastFrame = -1;
			}
			
			framesDelta = lastFrame - firstFrame + 1;
		}
		
		public function hasPositionOnFrame(_frame : Number) : Boolean {
			return getPositionIndexOnFrame(_frame) >= 0;
		}
		
		public function getPositionIndexOnFrame(_frame : Number) : Number {
			for (var i = 0; i < positions.length; i++) {
				if (positions[i].frame == _frame) {
					return i;
				}
			}
			
			return -1;
		}
		
		public function getInterpolatedPosition(_frame : Number) : Number {
			if (_frame < firstFrame || _frame > lastFrame) {
				return -1;
			}
			
			if (hasPositionOnFrame(_frame) == true) {
				return getPositionOnFrame(_frame);
			}
			
			var frameBefore : Number = getFrameBefore(_frame);
			var frameAfter : Number = getFrameAfter(_frame);
			
			var positionBefore : Number = getPositionOnFrame(frameBefore);
			var positionAfter : Number = getPositionOnFrame(frameAfter);
			var percentageBetweenFrames : Number = MathUtil.getPercentage(_frame, frameBefore, frameAfter);
			
			return MathUtil.lerp(positionBefore, positionAfter, percentageBetweenFrames);
		}
		
		public function getPositionOnFrame(_frame : Number) : Number {
			var index : Number = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				return positions[index].position;
			}
			
			return -1;
		}
		
		public function getFrameBefore(_frame : Number) : Number {
			for (var i = positions.length - 1; i >= 0; i--) {
				if (positions[i].frame < _frame) {
					return positions[i].frame;
				}
			}
			
			return -1;
		}
		
		public function getFrameAfter(_frame : Number) : Number {
			for (var i = 0; i < positions.length; i++) {
				if (positions[i].frame > _frame) {
					return positions[i].frame;
				}
			}
			
			return -1;
		}
		
		private function sortPositions() {
			positions.sort(function(a : SyncPosition, b : SyncPosition) {
				return a.frame - b.frame;
			});
		}
	}
}