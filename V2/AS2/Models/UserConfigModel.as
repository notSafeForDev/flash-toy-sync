class Models.UserConfigModel {
		
	public static var connectionKey : String = "";
	public static var showFullscreenButton : Boolean = true;
	public static var orgasmSections : Object = {
		showIndicatorBefore: true,
		overrideSyncedStrokes: {
			enabled: false,
			strokeLength: 50,
			strokeDuration: 0.25
		}
	}
	public static var editor : Object = {
		enabled: false
	}
}