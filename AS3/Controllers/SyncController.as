package Controllers {
	
	import flash.display.MovieClip;
	import flash.utils.setTimeout;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	import Models.SyncModel;
	import Models.AnimationModel;
	import Models.UserConfigModel;
	import Global.GlobalEvents;
	import Types.SyncSection;
	import Utils.ObjectUtil;
	import Components.HandyAPI;
	
	public class SyncController {
		
		var lastFrame : int = -1;
		var currentSectionIndex : int = -1;
		var currentSectionChild : MovieClip;
		var currentSectionRepeatCount : int = 0;
		var currentSectionMaxRepeatCount : int = -1;
		var handyAPI : HandyAPI;
		
		function SyncController() {
			handyAPI = new HandyAPI();
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.userConfig.loaded.listen(function(e : Object) {
				handyAPI.connectionKey = UserConfigModel.connectionKey;
			});
			
			GlobalEvents.events.animationData.loaded.listen(function(e : Object) {
				onAnimationDataLoaded(e.data);
			});
			
			GlobalEvents.events.animation.loaded.listen(function(e : Object) {
				SyncModel.animation = AnimationModel.animation;
				SyncModel.childSelected = AnimationModel.animation;
				addKeyboardEventListeners();
			});
			
			GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
				onAnimationFrameUpdate();
			});
			
			GlobalEvents.events.hierarchyPanel.childSelected.listen(function(e : Object) {
				SyncModel.childSelected = e.child;
				var path : Array = SyncSection.getChildPath(e.child);
				trace(path);
				var childFromPath : MovieClip = SyncSection.getChildFromPath(AnimationModel.animation, path);
				trace(childFromPath == e.child);
				GlobalEvents.events.sync.childSelected.emit({child: e.child});
			});
			
			GlobalEvents.events.positionIndicatorPanel.marked.listen(function(e : Object) {
				onPositionMarked(e.position);
			});
			
			GlobalEvents.events.exportPanel.json.listen(function() {
				onExportJSON();
			});
			
			GlobalEvents.events.exportPanel.csv.listen(function() {
				onExportCSV();
			});
		}
		
		function addKeyboardEventListeners() {
			if (UserConfigModel.showEditor == false) {
				return;
			}
			
			SyncModel.childSelected.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) {
				if (e.keyCode == Keyboard.MINUS || e.keyCode == Keyboard.NUMPAD_SUBTRACT) {
					onPositionRemoved();
				}
			});
		}
		
		function onAnimationDataLoaded(data : Object) {
			SyncModel.fps = data.fps;
			
			for (var iPart : Number = 0; iPart < data.parts.length; iPart++) {
				for (var iSection : Number = 0; iSection < data.parts[iPart].sections.length; iSection++) {
					var section : SyncSection = new SyncSection(data.parts[iPart].path);
					SyncModel.sections.push(section);
					section.activeWhile = data.parts[iPart].activeWhile;
					for (var frameKey : String in data.parts[iPart].sections[iSection]) {
						section.setPosition(parseInt(frameKey), data.parts[iPart].sections[iSection][frameKey]);
					}
				}
			}
		
			GlobalEvents.events.syncData.load.emit();
			
			handyAPI.prepareSync(data.csv, function(e : Object) {
				if (e.error != undefined) {
					GlobalEvents.events.status.update.emit({status: e.error});
				}
				GlobalEvents.events.syncData.loaded.emit();
			});
		}
		
		function onAnimationFrameUpdate() {
			var sectionIndex : int = SyncModel.getCurrentSectionIndex();
			
			if (sectionIndex < 0 || AnimationModel.isForceStopped == true) {
				if (currentSectionIndex >= 0) {
					handyAPI.syncStop();
					trace("stop");
				}
				currentSectionIndex = -1;
				return;
			}
			
			if (sectionIndex != currentSectionIndex) {
				currentSectionIndex = sectionIndex;
				currentSectionChild = SyncSection.getChildFromPath(AnimationModel.animation, SyncModel.sections[sectionIndex].childPath);
				currentSectionRepeatCount = 0;
				currentSectionMaxRepeatCount = SyncModel.getNumberOfTimesToRepeatSection(sectionIndex);
				lastFrame = currentSectionChild.currentFrame;
				onPlayingSection();
			}
			
			if (currentSectionChild.currentFrame < lastFrame) {
				currentSectionRepeatCount = (currentSectionRepeatCount + 1) % currentSectionMaxRepeatCount;
				
				if (currentSectionRepeatCount == 0) {
					onPlayingSection();
				}
			}
			
			lastFrame = currentSectionChild.currentFrame;
		}
		
		function onPlayingSection() {
			var startCSVMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
			
			var offsetMiliseconds : int = SyncModel.getMilisecondsForFrame(currentSectionChild.currentFrame - SyncModel.sections[currentSectionIndex].firstFrame);
			
			handyAPI.syncPlay(startCSVMiliseconds[currentSectionIndex] + offsetMiliseconds, function(e : Object) {
				// trace(JSON.stringify(e));
			});
		}
		
		function onPositionMarked(_position : Number) {
			if (SyncModel.markedSection != null && SyncModel.markedSection.isForChild(AnimationModel.childSelected) == false) {
				throw "Unable to set sync position, there's currently a marked section with a different child than the selected one";
			}
			
			var hadNoMarkedSection : Boolean = SyncModel.markedSection == null;
			
			var sectionIndex : int = SyncModel.getCurrentSectionIndex();
			if (sectionIndex >= 0 && SyncModel.sections[sectionIndex].isForChild(AnimationModel.childSelected) == false) {
				sectionIndex = -1;
			}
			
			if (hadNoMarkedSection == true) {
				SyncModel.markedSection = new SyncSection(SyncSection.getChildPath(AnimationModel.childSelected));
			}
			
			if (sectionIndex >= 0 && SyncModel.markedSection != SyncModel.sections[sectionIndex]) {
				SyncModel.markedSection.mergeWithSection(SyncModel.sections[sectionIndex]);
				SyncModel.sections.splice(sectionIndex, 1);
			}
			
			if (hadNoMarkedSection == true) {
				SyncModel.markedSectionInsertIndex = sectionIndex;
				if (sectionIndex < 0) {
					SyncModel.sections.push(SyncModel.markedSection);
				}
				else {
					SyncModel.sections.splice(sectionIndex, 0, SyncModel.markedSection);
				}
			}
			
			SyncModel.markedSection.setPosition(AnimationModel.childCurrentFrame, _position);
			
			GlobalEvents.events.export.clear.emit();
		}
		
		function onPositionRemoved() {
			var sectionIndex : int = SyncModel.getCurrentSectionIndex();
			if (sectionIndex >= 0 && SyncModel.sections[sectionIndex].isForChild(AnimationModel.childSelected) == false) {
				sectionIndex = -1;
			}
			
			if (SyncModel.markedSection != null && SyncModel.markedSection.isForChild(AnimationModel.childSelected) == false) {
				throw "Unable to remove sync position, there's currently a marked section with a different child than the selected one";
			}
			if (SyncModel.markedSection != null && SyncModel.markedSection.isFrameWithinSection(AnimationModel.childCurrentFrame) == false) {
				throw "Unable to remove sync position, the current frame is not within the marked section";
			}
			if (SyncModel.markedSection == null && sectionIndex < 0) {
				throw "Unable to remove sync position, the current frame is not within a section";
			}
			
			if (SyncModel.markedSection == null) {
				SyncModel.markedSection = new SyncSection(SyncSection.getChildPath(AnimationModel.childSelected));
				SyncModel.markedSection.mergeWithSection(SyncModel.sections[sectionIndex]);
			}
			
			SyncModel.markedSection.removePosition(AnimationModel.childCurrentFrame);
			
			if (SyncModel.markedSection.positions.length == 0) {
				SyncModel.markedSection = null;
				SyncModel.sections.splice(sectionIndex, 1);
			}
			
			GlobalEvents.events.export.clear.emit();
		}
		
		function onExportJSON() {
			if (SyncModel.markedSection == null) {
				return;
			}
			
			var jsonLines : Array = [];
			
			jsonLines.push("{");
			for (var i = 0; i < SyncModel.markedSection.positions.length; i++) {
				var line : String = '\t"' + SyncModel.markedSection.positions[i].frame + '": ' + SyncModel.markedSection.positions[i].position;
				if (i < SyncModel.markedSection.positions.length - 1) {
					line += ",";
				}
				jsonLines.push(line);
			}
			jsonLines.push("}");
			
			var json : String = jsonLines.join("\n");
			GlobalEvents.events.export.json.emit({json: json});
			trace(json);
			
			SyncModel.markedSection = null;
		}
		
		function onExportCSV() {
			var csvLines : Array = ['"{""type"":""handy""}",'];
			var startCSVMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
			
			for (var iSection : int = 0; iSection < SyncModel.sections.length; iSection++) {
				var section : SyncSection = SyncModel.sections[iSection];
				var repeatSection : int = SyncModel.getNumberOfTimesToRepeatSection(iSection);
				var framesDelta : int = (section.lastFrame - section.firstFrame) + 1;
				
				for (var iRepeat : int = 0; iRepeat < repeatSection; iRepeat++) {
					var frameOffset : Number = framesDelta * iRepeat;
					
					for (var iFrame : int = 0; iFrame < section.positions.length; iFrame++) {
						var frameMiliseconds : int = SyncModel.getMilisecondsForFrame(frameOffset + section.positions[iFrame].frame - section.firstFrame);
						var csvMiliseconds : int = startCSVMiliseconds[iSection] + frameMiliseconds;
						csvLines.push(csvMiliseconds + "," + section.positions[iFrame].position);
					}
				}
			}
			
			var csv : String = csvLines.join("\n");
			GlobalEvents.events.export.csv.emit({csv: csv});
			trace(csv);
		}
	}
}