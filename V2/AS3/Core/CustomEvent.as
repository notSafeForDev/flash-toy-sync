package Core {
	
	public class CustomEvent {
		
		private var listeners = [];
		
		public function CustomEvent() {
			listeners = [];
		}
		
		public function listen(_scope : *, _handler : Function) {
			listeners.push({
				handler: _handler, once: false 
			});
		}
		
		public function listenOnce(_scope : *, _handler : Function) {
			listeners.push({
				handler: _handler, once: true 
			});
		}
		
		public function emit(args : * = undefined) {
			for (var i : Number = 0; i < listeners.length; i++) {
				this.listeners[i].handler(args);
				if (this.listeners[i].once == true) {
					this.listeners.splice(i, 1);
					i--;
				}
			}
		}
	}
}