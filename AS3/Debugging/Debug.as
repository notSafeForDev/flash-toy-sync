package Debugging {
	
	public class Debug {
		
		public static function log(...rest) {
			trace(rest, new Error().getStackTrace().split("\n")[2]);
		}
	}
}