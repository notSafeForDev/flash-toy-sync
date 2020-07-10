import Core.*;

class Controllers.AnimationController {
	
	function AnimationController(_animationContainer : MovieClip) {
		var swfLoader : SWFLoader = new SWFLoader();
		swfLoader.browse(function(_fileName : String) {
			trace(_fileName);
		});
	}
}