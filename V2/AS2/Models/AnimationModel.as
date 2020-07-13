class Models.AnimationModel {
	
	public static var hasData : Boolean = false;
	public static var sourceWidth : Number = 550;
	public static var sourceHeight : Number = 400;
	
	public static var animation : MovieClip;
	public static var childSelected : MovieClip;
	
	public static var isChildForceStopped : Boolean = false;
	
	public static var childFirstFrameInLoop : Number;
	public static var childLastFrameInLoop : Number;
	public static var isChildFirstFrameInLoopDetermained : Boolean = false;
	public static var isChildLastFrameInLoopDetermained : Boolean = false;
}