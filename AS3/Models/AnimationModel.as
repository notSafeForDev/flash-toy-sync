package Models {
	
	import flash.display.MovieClip;

	public class AnimationModel {
		
		public static var animation : MovieClip;
		public static var isForceStopped : Boolean = false;
		
		public static var fps : Number = -1;
		public static var currentFrame : Number = -1;
		
		public static var width : Number = -1;
		public static var height : Number = -1;
		
		public static var childSelected : MovieClip;
		public static var childCurrentFrame : Number = -1;
		public static var childFirstFrameInSection : Number = -1;
		public static var childLastFrameInSection : Number = -1;
		public static var isChildFirstFrameInSectionDetermained : Boolean = false;
		public static var isChildLastFrameInSectionDetermained : Boolean = false;
	}
}