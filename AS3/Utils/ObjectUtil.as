package Utils {
	
	public class ObjectUtil {
		
		public static function getKeys(_object : Object) : Array {
			var keys : Array = [];
			
			for (var key : String in _object) {
				keys.push(key);
			}
			
			return keys;
		}
	}
}