import Global.GlobalEvents;
import Components.HandyCommands;
import Components.JSON;
import Utils.ObjectUtil;

import Models.SyncModel;
import Models.AnimationModel;

class Controllers.SyncController {
	
	var handyCommands : HandyCommands;
	var animationData : Object;
	
	var isPlaying : Boolean = true;
	var lastFrame : Number = -1;

	var currentSectionStartFrame : Number = -1;
	var currentSectionLastPlayedFrame : Number = -1;
	var currentSectionRepeatCount : Number = 0;
	
	function SyncController() {
		var self = this;
		
		handyCommands = new HandyCommands();
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		var self = this;
		
		GlobalEvents.events.userConfig.loaded.listen(function(e : Object) {
			self.onUserConfigLoaded(e);
		});
		GlobalEvents.events.animationData.loaded.listen(function(e : Object) {
			self.onAnimationDataLoaded(e);
		});
		GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
			self.onAnimationFrameUpdate(e);
		});
		GlobalEvents.events.positionIndicator.marked.listen(function(e : Object) {
			self.onPositionMarked(e);
		});
		GlobalEvents.events.controlPanel.exportPositions.listen(function() {
			self.onExportPositions();
		});
		GlobalEvents.events.controlPanel.exportCSV.listen(function() {
			self.onExportCSV();
		});
	}
	
	function onUserConfigLoaded(e : Object) {
		handyCommands.connectionKey = e.config.connectionKey;
	}
	
	function onAnimationDataLoaded(e : Object) {
		var self = this;
		
		animationData = e.animationData;
		
		SyncModel.sections = animationData.sections;
		
		handyCommands.prepareSync(e.animationData.csv, function(serverResponse : Object) {
			trace(JSON.stringify(serverResponse));
			GlobalEvents.events.syncData.loaded.emit({serverResponse: serverResponse});
		});
	}
	
	function onAnimationFrameUpdate(e : Object) {
		if (e.frame == lastFrame) {
			stopPlaying();
			return;
		}
		
		var haveJumpedFrame : Boolean = e.frame != lastFrame + 1;
		var isStartOfSection : Boolean = SyncModel.isStartOfSectionAtFrame(e.frame);
		var sectionIndex : Number = SyncModel.getSectionIndexForFrame(e.frame);
		
		if (haveJumpedFrame == false && isStartOfSection == true) {
			onPlayingSection(sectionIndex, e.frame);
		}
		else if (haveJumpedFrame == true && sectionIndex >= 0) {
			onPlayingSection(sectionIndex, e.frame);
		}
		else if (haveJumpedFrame == true) {
			stopPlaying();
		}
		
		lastFrame = e.frame;
	}
	
	function onPlayingSection(_index : Number, _frame : Number) {
		var startFrame : Number = SyncModel.getStartFrameForSection(_index);
		var sectionId : String = SyncModel.getIdForFrame(startFrame);
		var seconds : Number = _frame / animationData.fps;
		var miliseconds : Number = Math.floor(seconds * 1000);
		
		if (currentSectionStartFrame == startFrame) {
			currentSectionRepeatCount = (currentSectionRepeatCount + 1) % SyncModel.sectionMaxRepeatCount;
		} else {
			currentSectionRepeatCount = 0;
			currentSectionLastPlayedFrame = startFrame;
		}
		
		if (currentSectionRepeatCount == 0) {
			handyCommands.syncPlay(parseFloat(sectionId + miliseconds));
		}
		
		isPlaying = true;
		currentSectionStartFrame = startFrame;
	}
	
	function onPositionMarked(e : Object) {
		SyncModel.markPosition(e.position, AnimationModel.currentFrame);
	}
	
	function onExportPositions() {
		trace("{");
		for (var i : Number = 0; i < SyncModel.markedPositions.length; i++) {
			var line : String = '\t"' + SyncModel.markedPositions[i].frame + '": ' + SyncModel.markedPositions[i].position;
			if (i < SyncModel.markedPositions.length - 1) {
				line += ",";
			}
			trace(line);
		}
		trace("}");
		
		SyncModel.addSectionFromMarkedPositions();
		SyncModel.markedPositions = [];
	}
	
	function onExportCSV() {
		trace('"{""type"":""handy""}",');
			
		for (var i : Number = 0; i < SyncModel.sections.length; i++) {
			var sectionKeys : Array = ObjectUtil.getKeys(SyncModel.sections[i]);
			var firstFrame : Number = parseFloat(sectionKeys[sectionKeys.length - 1]);
			var lastFrame : Number = parseFloat(sectionKeys[0]);
			var id : String = SyncModel.getIdForFrame(firstFrame);
			var sectionDurationMiliseconds : Number = Math.floor(((lastFrame - firstFrame) / AnimationModel.fps) * 1000);
			
			for (var iRepeat : Number = 0; iRepeat < SyncModel.sectionMaxRepeatCount; iRepeat++) {
				var timeOffset : Number = iRepeat * sectionDurationMiliseconds;
				
				// We iterate in reverse as the keys are in reverse order in the sections, probably due to JSON.parse
				for (var iKey : Number = sectionKeys.length - 1; iKey >= 0; iKey--) {
					var key = sectionKeys[iKey];
					var miliseconds : Number = Math.floor((parseFloat(key) / AnimationModel.fps) * 1000) + timeOffset;
					var line : String = id + miliseconds + "," + SyncModel.sections[i][key];
					trace(line);
				}
			}
			
			// We iterate in reverse as the keys are in reverse order in the sections, probably due to JSON.parse
			for (var iKey : Number = sectionKeys.length - 1; iKey >= 0; iKey--) {
				var key = sectionKeys[iKey];
				var miliseconds : Number = Math.floor((parseFloat(key) / AnimationModel.fps) * 1000);
				var line : String = id + miliseconds + "," + SyncModel.sections[i][key];
				trace(line);
			}
		}
	}
	
	function stopPlaying() {
		if (isPlaying == false) {
			return;
		}
		
		// This also stops the "video" sync
		handyCommands.send(100, 1000);
		isPlaying = false;
	}
}