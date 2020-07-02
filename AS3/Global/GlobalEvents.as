package Global {
	
	import Components.CustomEvent;
	
	public class GlobalEvents {
		
		public static var events = {};
		
		public static function init() {
			events = {
				userConfig: {
					loaded: new CustomEvent()
				},
				animationData: {
					loaded: new CustomEvent()
				},
				syncData: {
					load: new CustomEvent(),
					loaded: new CustomEvent()
				},
				animation: {
					loaded: new CustomEvent(),
					frameUpdate: new CustomEvent(),
					forceStopped: new CustomEvent(),
					resumed: new CustomEvent()
				},
				hierarchyPanel: {
					childSelected: new CustomEvent()
				},
				playControlsPanel: {
					play: new CustomEvent(),
					stop: new CustomEvent(),
					stepBackwards: new CustomEvent(),
					stepForwards: new CustomEvent()
				},
				positionIndicatorPanel: {
					marked: new CustomEvent()
				},
				sync: {
					childSelected: new CustomEvent()
				},
				exportPanel: {
					json: new CustomEvent(),
					csv: new CustomEvent()
				},
				export: {
					json: new CustomEvent(),
					csv: new CustomEvent(),
					clear: new CustomEvent()
				},
				status: {
					update: new CustomEvent()
				}
			}
		}
	}
}
