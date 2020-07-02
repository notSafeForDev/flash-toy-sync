package Views {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.DisplayObject;
	
	public class HierarchyField extends MovieClip {
		
		public var textName : TextField;
		public var textFrame : TextField;
		public var highlight : DisplayObject;
		public var animationChild : MovieClip;
		
		function HierarchyField() {
			textName = TextName;
			textFrame = TextFrame;
			highlight = Highlight;
			
			textName.mouseEnabled = false;
			textFrame.mouseEnabled = false;
		}
	}
}