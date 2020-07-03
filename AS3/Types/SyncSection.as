package Types {
	
	import flash.display.MovieClip;
	
	import Types.SyncPosition;
	import Utils.MathUtil;
	
	public class SyncSection {
		
		public var childPath : Array;
		public var activeWhile : Object = {};
		public var firstFrame : Number = -1;
		public var lastFrame : Number = -1;
		public var positions : Vector.<SyncPosition> = new Vector.<SyncPosition>();
		
		public static var randomInstanceNamePrefix : String = "instance";
		
		function SyncSection(_childPath : Array) {
			childPath = _childPath;
		}
		
		public static function getChildPath(_child : MovieClip) : Array {
			var path : Array = [];
			var currentChild : MovieClip = _child;
			var children : Vector.<MovieClip> = new Vector.<MovieClip>();
			children.push(currentChild);
			
			while (currentChild.parent != null && currentChild.parent is MovieClip) {
				currentChild = MovieClip(currentChild.parent);
				children.push(currentChild);
			}
			
			children.reverse();
			
			// Starting from 1 to not include root
			for (var i = 1; i < children.length; i++) {
				var name : String = children[i].name;
				
				if (name.indexOf(randomInstanceNamePrefix) == 0) {
					name = "";
					while (name.length < i) {
						name += "#";
					}
					name += children[i].parent.getChildIndex(children[i]);
				}
				
				path.push(name);
			}
			
			return path;
		}
		
		public static function getChildFromPath(_root : MovieClip, _path : Array) : MovieClip {
			var currentChild : MovieClip = _root;
			
			for (var i : int = 0; i < _path.length; i++) {
				var pathCurrent : String = _path[i];
				if (pathCurrent.indexOf("#") == 0) {
					var lastHashIndex : int = pathCurrent.lastIndexOf("#");
					var childIndex : int = parseInt(pathCurrent.substr(lastHashIndex + 1));
					if (childIndex < currentChild.numChildren && currentChild.getChildAt(childIndex) is MovieClip) {
						currentChild = MovieClip(currentChild.getChildAt(childIndex));
					}
					else {
						return null;
					}
				}
				else {
					currentChild = MovieClip(currentChild.getChildByName(pathCurrent));
				}
				
				if (currentChild == null) {
					return null;
				}
			}
			
			return currentChild;
		}
		
		public function isForChild(_child : MovieClip) : Boolean {
			if (_child == null) {
				return false;
			}
			
			var path : Array = getChildPath(_child);
			
			if (path.length != childPath.length) {
				return false;
			}
			
			for (var i = 0; i < childPath.length; i++) {
				if (path[i] != childPath[i]) {
					return false;
				}
			}
			
			return true;
		}
		
		public function isFrameWithinSection(_frame : int) : Boolean {
			return _frame >= firstFrame && _frame <= lastFrame;
		}
		
		public function mergeWithSection(_section : SyncSection) {
			for (var i : int = 0; i < _section.positions.length; i++) {
				setPosition(_section.positions[i].frame, _section.positions[i].position);
			}
		}
		
		public function setPosition(_frame : int, _position : Number) {
			var index : int = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				positions[index].position = _position;
			}
			else {
				positions.push(new SyncPosition(_frame, _position));
				sortPositions();
				firstFrame = positions[0].frame;
				lastFrame = positions[positions.length - 1].frame;
			}
		}
		
		public function removePosition(_frame : int) {
			var index : int = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				positions.splice(index, 1);
			}
		}
		
		public function removePositionOnFrame(_frame : int) {
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
		}
		
		public function hasPositionOnFrame(_frame : int) : Boolean {
			return getPositionIndexOnFrame(_frame) >= 0;
		}
		
		public function getPositionIndexOnFrame(_frame : int) : int {
			for (var i = 0; i < positions.length; i++) {
				if (positions[i].frame == _frame) {
					return i;
				}
			}
			
			return -1;
		}
		
		public function getInterpolatedPosition(_frame : int) : Number {
			if (_frame < firstFrame || _frame > lastFrame) {
				return -1;
			}
			
			if (hasPositionOnFrame(_frame) == true) {
				return getPositionOnFrame(_frame);
			}
			
			var frameBefore : int = getFrameBefore(_frame);
			var frameAfter : int = getFrameAfter(_frame);
			
			var positionBefore : Number = getPositionOnFrame(frameBefore);
			var positionAfter : Number = getPositionOnFrame(frameAfter);
			var percentageBetweenFrames : Number = MathUtil.getPercentage(_frame, frameBefore, frameAfter);
			
			return MathUtil.lerp(positionBefore, positionAfter, percentageBetweenFrames);
		}
		
		public function getPositionOnFrame(_frame : int) : Number {
			var index : int = getPositionIndexOnFrame(_frame);
			
			if (index >= 0) {
				return positions[index].position;
			}
			
			return -1;
		}
		
		public function getFrameBefore(_frame : int) : int {
			for (var i = positions.length - 1; i >= 0; i--) {
				if (positions[i].frame < _frame) {
					return positions[i].frame;
				}
			}
			
			return -1;
		}
		
		public function getFrameAfter(_frame : int) : int {
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