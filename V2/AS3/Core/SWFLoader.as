package Core {
	
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class SWFLoader {
		
		public var swf : MovieClip;
		
		public var onError : Function;
		
		function SWFLoader() {
			
		}
		
		public function browse(_onSelected : Function) {
			var fileReference : FileReference = new FileReference();
			var fileFilter : FileFilter = new FileFilter("swf", "*.swf");
			fileReference.browse([fileFilter]);
			
			fileReference.addEventListener(Event.SELECT, onSelect);
			
			function onSelect(e : Event) {
				_onSelected(fileReference.name);
			}
		}
		
		public function load(_path : String, _container : MovieClip, _onLoaded : Function) {			
			var loader : Loader = new Loader();
			
			function onLoaderComplete(e : Event) {
				try {
					 swf = MovieClip(loader.content);
				} 
				catch (error) {
					if (onError != null) {
						onError(error);
					}
					return;
				}
				
				_container.addChild(loader);
				_onLoaded(swf);
			}
			
			function onLoaderError(e : IOErrorEvent) {
				onError(e.text);
			}
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			
			if (onError != null) {
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			}
			
			loader.load(new URLRequest(_path));
		}
	}
}