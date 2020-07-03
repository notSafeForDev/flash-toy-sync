package Types {
	
	import flash.display.MovieClip;
	
	public class ChildInfo {
		
		public var child : MovieClip;
		public var path : Array;
		
		public static var randomInstanceNamePrefix : String = "instance";
		
		function ChildInfo(_child : MovieClip, _path : Array) {
			child = _child;
			path = _path;
		}
	}
}