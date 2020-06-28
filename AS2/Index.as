import Global.GlobalEvents;
import Components.JSON;

import Controllers.UserConfigController;
import Controllers.SyncController;
import Controllers.AnimationController;
import Controllers.ControlPanelController;
import Controllers.PositionIndicatorController;
import Controllers.KeyboardInputController;
import Controllers.ModifiersController;

import Models.AnimationModel;

import Utils.ObjectUtil;

class Index {
	
	function Index(_stage : Stage, _root : MovieClip) {
		_stage.scaleMode = "showAll";
		
		_root.Container._lockroot = true;
		
		_root.DownloadingAnimation._visible = false;
		_root.ButtonFullscreen._visible = false;
		_root.ButtonSkipIntro._visible = false;
		
		GlobalEvents.init();
		
		new AnimationController(_root.Container);
		new SyncController();
		new UserConfigController();
		new ControlPanelController(_root.ControlPanelContainer);
		new PositionIndicatorController(_root.ControlPanelContainer.PositionIndicator);
		new KeyboardInputController();
		new ModifiersController(_root.Container);
		
		GlobalEvents.events.userConfig.loaded.listen(function(e : Object) {
			_root.ButtonFullscreen._visible = e.config.fullscreenButton;
		});
		
		GlobalEvents.events.animationData.loaded.listen(function() {
			_root.DownloadingAnimation._visible = true;
		});
		
		GlobalEvents.events.syncData.loaded.listen(function(e : Object) {
			_root.DownloadingAnimation._visible = false;
			if (e.serverResponse.error != undefined) {
				_root.StatusText.text = e.serverResponse.error;
			}
		});
		
		GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
			_root.ButtonSkipIntro._visible = e.frame < AnimationModel.startFrame;
			// trace(ObjectUtil.getKeys(_root.Container._root));
		});
		
		_root.ButtonFullscreen.onRelease = function() {
			Stage.displayState = Stage.displayState == "normal" ? "fullscreen" : "normal";
		}
		
		_root.ButtonSkipIntro.onRelease = function() {
			GlobalEvents.events.index.frameChange.emit({frame: AnimationModel.startFrame});
		}
	}
	
	function onEnterFrame(_frame : Number) {
		GlobalEvents.events.frame.update.emit();
	}
}