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
		SyncModel.fps = animationData.fps;
		
		handyCommands.prepareSync(e.animationData.csv, function(serverResponse : Object) {
			trace(JSON.stringify(serverResponse));
			GlobalEvents.events.syncData.loaded.emit({serverResponse: serverResponse});
		});
	}
	
	function onAnimationFrameUpdate(e : Object) {
		if (e.frame == lastFrame || AnimationModel.isForceStopped == true) {
			stopPlaying();
			return;
		}
		
		var haveJumpedFrame : Boolean = e.frame != lastFrame + 1;
		var isStartOfSection : Boolean = SyncModel.isStartOfSectionAtFrame(e.frame);
		var sectionIndex : Number = SyncModel.getSectionIndexForFrame(e.frame);
		
		if (SyncModel.getInterpolatedPositionAtFrame(e.frame) < 0) {
			stopPlaying();
		}
		else if (haveJumpedFrame == false && isStartOfSection == true) {
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
		
		if (currentSectionStartFrame == startFrame) {
			currentSectionRepeatCount = (currentSectionRepeatCount + 1) % SyncModel.sectionMaxRepeatCount;
		} else {
			currentSectionRepeatCount = 0;
		}
		
		if (currentSectionRepeatCount == 0) {
			handyCommands.syncPlay(SyncModel.getCSVMiliseconds2(_index, AnimationModel.currentFrame));
		}
		
		isPlaying = true;
		currentSectionStartFrame = startFrame;
	}
	
	function onPositionMarked(e : Object) {
		SyncModel.markPosition(e.position, AnimationModel.currentFrame);
	}
	
	function onExportPositions() {
		var jsonLines : Array = [];
		
		jsonLines.push("{");
		for (var i : Number = 0; i < SyncModel.markedPositions.length; i++) {
			var line : String = '\t"' + SyncModel.markedPositions[i].frame + '": ' + SyncModel.markedPositions[i].position;
			if (i < SyncModel.markedPositions.length - 1) {
				line += ",";
			}
			jsonLines.push(line);
		}
		jsonLines.push("}");
		
		var jsonString : String = jsonLines.join("\n");
		trace(jsonString);
		GlobalEvents.events.export.json.emit({json: jsonString});
		
		SyncModel.addSectionFromMarkedPositions();
		SyncModel.markedPositions = [];
	}
	
	function onExportCSV() {
		var csvLines : Array = [];
		
		csvLines.push('"{""type"":""handy""}",');
			
		for (var i : Number = 0; i < SyncModel.sections.length; i++) {
			var frames : Array = SyncModel.getFramesInSection(i);
			var positions : Array = SyncModel.getPositionsInSection(i);
			var framesDelta : Number = frames[frames.length - 1] - frames[0];
			
			for (var iRepeat : Number = 0; iRepeat < SyncModel.sectionMaxRepeatCount; iRepeat++) {
				for (var iFrame : Number = 0; iFrame < frames.length; iFrame++) {
					var csvMiliseconds : Number = SyncModel.getCSVMiliseconds2(i, framesDelta * iRepeat + frames[iFrame]);
					csvLines.push(csvMiliseconds + "," + positions[iFrame]);
				}
			}
		}
		
		var csv : String = csvLines.join("\n");
		trace(csv);
		GlobalEvents.events.export.csv.emit({csv: csv});
	}
	
	function stopPlaying() {
		if (isPlaying == false) {
			return;
		}
		
		trace("stopping");
		
		// This also stops the "video" sync
		handyCommands.send(100, 1000);
		isPlaying = false;
	}
}