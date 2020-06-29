import Components.CustomEvent;

class Global.GlobalEvents {

	static var events : Object;
	
	static function init() {
		events = {
			index: {
				frameChange: new CustomEvent()
			},
			frame: {
				update: new CustomEvent()
			},
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
				frameUpdate: new CustomEvent(),
				forceStopped: new CustomEvent(),
				resumed: new CustomEvent()
			},
			controlPanel: {
				play: new CustomEvent(),
				stop: new CustomEvent(),
				stepBackwards: new CustomEvent(),
				stepForwards: new CustomEvent(),
				exportPositions: new CustomEvent(),
				exportCSV: new CustomEvent()
			},
			positionIndicator: {
				marked: new CustomEvent()
			},
			keyboard: {
				left: new CustomEvent(),
				right: new CustomEvent(),
				up: new CustomEvent(),
				down: new CustomEvent(),
				play: new CustomEvent(),
				remove: new CustomEvent()
			},
			export: {
				json: new CustomEvent(),
				csv: new CustomEvent()
			}
		}
	}
}