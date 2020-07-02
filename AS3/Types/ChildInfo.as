package Types {
	
	import flash.display.MovieClip;
	
	public class ChildInfo {
		
		public var child : MovieClip;
		public var path : Vector.<String>;
		
		function ChildInfo(_child : MovieClip, _path : Vector.<String>) {
			child = _child;
			path = _path;
		}
	}
}