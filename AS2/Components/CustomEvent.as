class Components.CustomEvent {
	
	private var listeners = [];
	
	function CustomEvent() {
		listeners = [];
	}
	
	function listen(handler : Function) {
		listeners.push({
			handler: handler, once: false 
		});
	}
	
	function listenOnce(handler : Function) {
		listeners.push({
			handler: handler, once: true 
		});
	}
	
	function emit(args) {
		for (var i : Number = 0; i < listeners.length; i++) {
			this.listeners[i].handler(args);
			if (this.listeners[i].once == true) {
				this.listeners.splice(i, 1);
				i--;
			}
		}
	}
}