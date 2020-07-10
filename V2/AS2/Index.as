import Core.*;

import Models.UserConfigModel;

import Controllers.AnimationController;
import Controllers.SyncController;
import Controllers.HierarchyPanelController;
import Controllers.PlayControlsPanelController;
import Controllers.PositionPanelController;
import Controllers.ExportPanelController;

import Global.GlobalEvents;

class Index {
	
	var root : MovieClip;
		
	function Index(_root : MovieClip) {
		root = _root;
		
		GlobalEvents.init();
		
		MovieClipUtil.setVisible(root.DownloadingAnimation, false);
		showFullscreenButton(false);
		showEditor(false);
		
		root.TextStatus.text = "";
		
		new AnimationController(_root.AnimationContainer);
		new SyncController(_root);
		new HierarchyPanelController(_root.HierarchyPanelContainer);
		new PlayControlsPanelController(_root.PlayControlsPanelContainer);
		new PositionPanelController(_root.PositionPanelContainer);
		new ExportPanelController(_root.ExportPanelContainer);
		
		JSONLoader.load("UserConfig.json", FunctionUtil.bind(this, onLoad));
		function onLoad(_config : Object) {
			if (_config.error != null) {
				GlobalEvents.events.status.update.emit({status: "Error: No UserConfig.json found in the base directory"});
				return;
			}
						
			for (var key : String in _config) {
				UserConfigModel[key] = _config[key];
			}
			
			showFullscreenButton(UserConfigModel.showFullscreenButton);
						
			GlobalEvents.events.userConfig.loaded.emit({config: _config});
		}
		
		var buttonFullscreen : UIButton = new UIButton(root.ButtonFullscreen);
		buttonFullscreen.onMouseDown = FunctionUtil.bind(this, function() {
			if (StageUtil.isWindowed(root) == true) {
				StageUtil.makeFullscreen(root);
			}
			else {
				StageUtil.makeWindowed(root);
			}
		});
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		GlobalEvents.events.animationData.loaded.listen(this, onAnimationDataLoaded);
		GlobalEvents.events.animation.loaded.listen(this, onAnimationLoaded);
		GlobalEvents.events.status.update.listen(this, onStatusUpdate);
	}
	
	function onAnimationDataLoaded(e : Object) {
		MovieClipUtil.setVisible(root.DownloadingAnimation, true);
	}
	
	function onAnimationLoaded(e : Object) {
		MovieClipUtil.setVisible(root.DownloadingAnimation, false);
		showEditor(UserConfigModel.editor.enabled);
	}
	
	function onStatusUpdate(e : Object) {
		root.TextStatus.text = e.status;
	}
	
	function showFullscreenButton(_state : Boolean) {
		try {
			root.ButtonFullscreen["_visible"] = _state;
		}
		catch (error) {
			root.ButtonFullscreen.visible = _state;
		}
	}
	
	function showEditor(_state : Boolean) {
		MovieClipUtil.setVisible(root.HierarchyPanelContainer, _state);
		MovieClipUtil.setVisible(root.PlayControlsPanelContainer, _state);
		MovieClipUtil.setVisible(root.PositionPanelContainer, _state);
		MovieClipUtil.setVisible(root.ExportPanelContainer, _state);
	}
	
	public function onEnterFrame() {
		GlobalEvents.events.frame.update.emit();
	}
}