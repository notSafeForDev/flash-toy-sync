﻿package Core {
	
	public class ArrayUtil {
		
		public static function indexOf(_array : Array, _searchElement : *) : Number {
			return _array.indexOf(_searchElement);
		}
		
		public static function lastIndexOf(_array : Array, _searchElement : *) : Number {
			return _array.lastIndexOf(_searchElement);
		}
	}
}