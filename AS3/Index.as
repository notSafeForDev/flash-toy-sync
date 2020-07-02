package {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	
	import Global.GlobalEvents;
	import Components.JSONLoader;
	import Controllers.AnimationController;
	import Controllers.SyncController;
	import Controllers.HierarchyPanelController;
	import Controllers.PlayControlsPanelController;
	import Controllers.PositionIndicatorPanelController;
	import Controllers.ExportPanelController;
	import Models.UserConfigModel;
	import Models.AnimationModel;
	
	public class Index {
	
		var root : MovieClip;
	
		function Index(_root : MovieClip) {
			GlobalEvents.init();
			
			root = _root;
			
			root.stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			root.DownloadingAnimation.visible = false;
			root.ButtonFullscreen.visible = false;
			root.TextStatus.mouseEnabled = false;
			root.TextStatus.text = "";
			
			showEditor(false);
			
			new HierarchyPanelController(root, root.HierarchyPanel);
			new PlayControlsPanelController(root, root.PlayControlsPanel);
			new PositionIndicatorPanelController(root, root.PositionIndicatorPanel);
			new ExportPanelController(root, root.ExportPanel);
			new AnimationController(root);
			new SyncController();
			
			JSONLoader.load("UserConfig.json", function(json : Object) {
				UserConfigModel.connectionKey = json.connectionKey;
				UserConfigModel.showEditor = json.showEditor;
				UserConfigModel.showFullscreenButton = json.showFullscreenButton;
				
				root.ButtonFullscreen.visible = UserConfigModel.showFullscreenButton;
				
				GlobalEvents.events.userConfig.loaded.emit({config: json});
			});
			
			var buttonFullscreen : DisplayObject = root.ButtonFullscreen;
			buttonFullscreen.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) {  
				if (root.stage.displayState == StageDisplayState.NORMAL) {
					root.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
				else {
					root.stage.displayState = StageDisplayState.NORMAL;
				}
			});
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.status.update.listen(function(e : Object) {
				root.TextStatus.text = e.status;
			});
			
			GlobalEvents.events.syncData.load.listen(function() {
				root.DownloadingAnimation.visible = true;
			});
			
			GlobalEvents.events.syncData.loaded.listen(function() {
				root.DownloadingAnimation.visible = false;
			});
			
			GlobalEvents.events.animation.loaded.listen(function(e : Object) {
				showEditor(UserConfigModel.showEditor);
				root.stage.frameRate = AnimationModel.fps;
				addBorders();
			});
		}
		
		function showEditor(_state : Boolean) {
			root.HierarchyPanel.visible = _state;
			root.PlayControlsPanel.visible = _state;
			root.PositionIndicatorPanel.visible = _state;
			root.ExportPanel.visible = _state;
		}
		
		function addBorders() {
			var width : Number = (root.stage.stageWidth - (AnimationModel.width * AnimationModel.animation.scaleX)) / 2;
			var height : Number = (root.stage.stageHeight - (AnimationModel.height * AnimationModel.animation.scaleY)) / 2;
			
			addBorder(0, 0, width, root.stage.stageHeight);
			addBorder(root.stage.stageWidth - width, 0, width, root.stage.stageHeight);
			addBorder(0, 0, root.stage.stageWidth, height);
			addBorder(0, root.stage.stageWidth - height, root.stage.stageWidth, height);
		}
		
		function addBorder(_x : Number, _y : Number, _width : Number, _height : Number) {
			var border : Shape = new Shape;
			border.graphics.beginFill(0x000000);
			border.graphics.drawRect(_x, _y, _width, _height);
			border.graphics.endFill();
			border.alpha = UserConfigModel.showEditor == true ? 0.9 : 1;
			root.addChildAt(border, 1);
		}
	}
}