import Core.*;
	
import Models.SyncModel;
import Models.AnimationModel;
import Models.UserConfigModel;

import Components.HandyAPI;

import Types.SyncSection;

import Global.GlobalEvents;

class Controllers.SyncController {
	
	var handyAPI : HandyAPI;
	
	var keyboardManager : KeyboardManager;
	
	var playingSectionIndex : Number = -1;
	var playingSectionChild : MovieClip;
	var playingSectionCurrentRepeatCount : Number = 0;
	var playingSectionMaxRepeatCount : Number = -1;
	
	var lastPlayedFrame : Number = -1;
	
	function SyncController(_root : MovieClip) {
		handyAPI = new HandyAPI();
		
		keyboardManager = new KeyboardManager(_root);
		keyboardManager.onKeyPressed = FunctionUtil.bind(this, onKeyPressed);
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		GlobalEvents.events.userConfig.loaded.listen(this, onUserConfigLoaded);
		GlobalEvents.events.animationData.loaded.listen(this, onAnimationDataLoaded);
		GlobalEvents.events.frame.update.listen(this, onFrameUpdate);
		GlobalEvents.events.animation.loaded.listen(this, onAnimationLoaded);
		GlobalEvents.events.hierarchyPanel.childSelected.listen(this, onHierarchyPanelChildSelected);
		GlobalEvents.events.positionPanel.marked.listen(this, onPositionPanelMarked);
	}
	
	function onUserConfigLoaded(e : Object) {
		if (e.config.error != undefined) {
			return;
		}
		
		handyAPI.connectionKey = e.config.connectionKey;
	}
	
	function onAnimationDataLoaded(e : Object) {
		if (e.data.error != undefined) {
			return;
		}
		
		SyncModel.fps = e.data.fps;
		
		for (var i : Number = 0; i < e.data.parts.length; i++) {
			var part : Object = e.data.parts[i];
			
			for (var iSection : Number = 0; iSection < part.sections.length; iSection++) {
				var section : Object = part.sections[iSection];
				var syncSection : SyncSection = new SyncSection(part.path);
				SyncModel.sections.push(syncSection);
				syncSection.activeWhile = part.activeWhile;
				
				for (var frame : String in section) {
					syncSection.setPosition(parseInt(frame), section[frame]);
				}
			}
		}
		
		handyAPI.syncPrepare(e.data.csv, function(_response : Object) {
			if (_response.error != undefined) {
				GlobalEvents.events.status.update.emit({status: _response.error});
			}
			trace(JSON.stringify(_response));
			GlobalEvents.events.syncData.loaded.emit({});
		});
	}
	
	function onAnimationLoaded(e : Object) {
		SyncModel.animation = AnimationModel.animation;
		SyncModel.childSelected = AnimationModel.animation;
	}
	
	function onFrameUpdate(e : Object) {
		if (SyncModel.animation == null) {
			return;
		}
		
		var sectionIndexToPlay : Number = SyncModel.getSectionIndexToPlay();
		
		if (sectionIndexToPlay < 0 || AnimationModel.isChildForceStopped == true) {
			if (handyAPI.isPlayingSync == true) {
				handyAPI.syncStop();
			}
			SyncModel.playingSectionChild = null;
			playingSectionIndex = -1;
			return;
		}
		
		var section : SyncSection = SyncModel.sections[sectionIndexToPlay];
			
		// It's important that we refresh the child each frame, for cases where the movieClip is changed, but the instance name stays the same
		// Or where a loop changes between different movieClips with identical motion, in which case we want to use child index instead of instance name
		playingSectionChild = MovieClipUtil.getChildFromPath(SyncModel.animation, section.childPath);
		SyncModel.playingSectionChild = playingSectionChild;
		
		if (sectionIndexToPlay != playingSectionIndex) {
			playingSectionIndex = sectionIndexToPlay;
			playingSectionCurrentRepeatCount = 0;
			playingSectionMaxRepeatCount = SyncModel.getNumberOfTimesToRepeatSection(sectionIndexToPlay);
			lastPlayedFrame = MovieClipUtil.getCurrentFrame(playingSectionChild);
			onStartPlayingSection();
		}
		
		if (MovieClipUtil.getCurrentFrame(playingSectionChild) < lastPlayedFrame) {
			playingSectionCurrentRepeatCount = (playingSectionCurrentRepeatCount + 1) % playingSectionMaxRepeatCount;
			
			if (playingSectionCurrentRepeatCount == 0) {
				onStartPlayingSection();
			}
		}
		
		lastPlayedFrame = MovieClipUtil.getCurrentFrame(playingSectionChild);
	}
	
	function onHierarchyPanelChildSelected(e : Object) {
		SyncModel.childSelected = e.child;
	}
	
	function onPositionPanelMarked(e : Object) {
		var sectionIndex : Number = SyncModel.getSectionIndexForChildSelected();
		
		if (SyncModel.markedSection == null) {
			if (sectionIndex >= 0) {
				SyncModel.markedSection = SyncModel.sections[sectionIndex];
			}
			else {
				SyncModel.markedSection = new SyncSection(MovieClipUtil.getChildPath(SyncModel.animation, SyncModel.childSelected));
				SyncModel.sections.push(SyncModel.markedSection);
			}
		}
		
		if (MovieClipUtil.getChildFromPath(SyncModel.animation, SyncModel.markedSection.childPath) != SyncModel.childSelected) {
			throw "Unable to mark sync position, there's a marked section with a different child than the one that is selected";
		}
		
		if (sectionIndex >= 0 && SyncModel.markedSection != SyncModel.sections[sectionIndex]) {
			SyncModel.markedSection.mergeWithSection(SyncModel.sections[sectionIndex]);
			SyncModel.sections.splice(sectionIndex, 1);
		}
		
		SyncModel.markedSection.setPosition(MovieClipUtil.getCurrentFrame(SyncModel.childSelected), e.position);
	}
	
	function onKeyPressed(_keyCode : Number) {
		if (UserConfigModel.editor.enabled == false) {
			return;
		}
		
		if (_keyCode == Keyboard.MINUS || _keyCode == Keyboard.NUMPAD_SUBTRACT) {
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(SyncModel.childSelected);
			var sectionIndex : Number = SyncModel.getSectionIndexForChildSelected();
			var hasPositionOnFrame : Boolean = SyncModel.hasPositionOnFrame();
			if (sectionIndex >= 0 && hasPositionOnFrame == true) {
				var section : SyncSection = SyncModel.sections[sectionIndex];
				section.removePosition(currentFrame);
			}
		}
	}
	
	function onStartPlayingSection() {
		var startCSVMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
		var currentFrame : Number = MovieClipUtil.getCurrentFrame(playingSectionChild);
		var offsetMiliseconds : Number = SyncModel.getMilisecondsForFrame(currentFrame - SyncModel.sections[playingSectionIndex].firstFrame);
		
		handyAPI.syncPlay(startCSVMiliseconds[playingSectionIndex] + offsetMiliseconds, function(e : Object) {
			// trace(JSON.stringify(e));
		});
	}
}