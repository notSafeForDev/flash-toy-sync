package Global {
	
	import Core.CustomEvent;
	
	public class GlobalEvents {
		
		public static var events : Object;
		
		public static function init() {
			
			events = {
				userConfig: {
					loaded: new CustomEvent()
				},
				animationData: {
					loaded: new CustomEvent()
				},
				syncData: {
					loaded: new CustomEvent()
				},
				animation: {
					loaded: new CustomEvent(),
					forceStopped: new CustomEvent(),
					resumed: new CustomEvent()
				},
				frame: {
					update: new CustomEvent()
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
				positionPanel: {
					marked: new CustomEvent()
				},
				exportPanel: {
					json: new CustomEvent(),
					csv: new CustomEvent()
				},
				export: {
					json: new CustomEvent(),
					csv: new CustomEvent()
				},
				status: {
					update: new CustomEvent()
				}
			}
		}
	}
}