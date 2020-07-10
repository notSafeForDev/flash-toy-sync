package Models {
	
	import flash.display.MovieClip;
	
	public class AnimationModel {
		
		public static var sourceWidth : Number;
		public static var sourceHeight : Number;
		
		public static var animation : MovieClip;
		public static var childSelected : MovieClip;
		
		public static var isChildForceStopped : Boolean = false;
		
		public static var childFirstFrameInLoop : Number;
		public static var childLastFrameInLoop : Number;
		public static var isChildFirstFrameInLoopDetermained : Boolean = false;
		public static var isChildLastFrameInLoopDetermained : Boolean = false;
	}
}