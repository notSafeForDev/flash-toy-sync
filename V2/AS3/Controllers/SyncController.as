package Controllers {
	
	import flash.display.MovieClip;
	
	import Core.*;
	
	import Models.SyncModel;
	import Models.AnimationModel;
	
	import Components.HandyAPI;
	
	import Types.SyncSection;
	
	import Global.GlobalEvents;
	
	public class SyncController {
		
		var handyAPI : HandyAPI;
		
		var playingSectionIndex : Number = -1;
		var playingSectionChild : MovieClip;
		var playingSectionCurrentRepeatCount : Number = 0;
		var playingSectionMaxRepeatCount : Number = -1;
		
		var lastPlayedFrame : Number = -1;
		
		function SyncController() {
			handyAPI = new HandyAPI();
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.userConfig.loaded.listen(onUserConfigLoaded);
			GlobalEvents.events.animationData.loaded.listen(onAnimationDataLoaded);
			GlobalEvents.events.frame.update.listen(onFrameUpdate);
			GlobalEvents.events.animation.loaded.listen(onAnimationLoaded);
			GlobalEvents.events.hierarchyPanel.childSelected.listen(onHierarchyPanelChildSelected);
			GlobalEvents.events.positionPanel.marked.listen(onPositionPanelMarked);
			GlobalEvents.events.exportPanel.json.listen(onExportPanelExportJSON);
			GlobalEvents.events.exportPanel.csv.listen(onExportPanelExportCSV);
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
				playingSectionIndex = -1;
				return;
			}
			
			if (sectionIndexToPlay != playingSectionIndex) {
				var section : SyncSection = SyncModel.sections[sectionIndexToPlay];
				playingSectionIndex = sectionIndexToPlay;
				playingSectionChild = MovieClipUtil.getChildFromPath(SyncModel.animation, section.childPath);
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
		
		function onStartPlayingSection() {
			var startCSVMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(playingSectionChild);
			var offsetMiliseconds : int = SyncModel.getMilisecondsForFrame(currentFrame - SyncModel.sections[playingSectionIndex].firstFrame);
			
			handyAPI.syncPlay(startCSVMiliseconds[playingSectionIndex] + offsetMiliseconds, function(e : Object) {
				// trace(JSON.stringify(e));
			});
		}
		
		function onExportPanelExportJSON(e : Object) {
			if (SyncModel.markedSection == null) {
				return;
			}
			
			var jsonLines : Array = [];
			
			jsonLines.push("{");
			for (var i : Number = 0; i < SyncModel.markedSection.positions.length; i++) {
				var line : String = '\t"' + SyncModel.markedSection.positions[i].frame + '": ' + SyncModel.markedSection.positions[i].position;
				if (i < SyncModel.markedSection.positions.length - 1) {
					line += ",";
				}
				jsonLines.push(line);
			}
			jsonLines.push("}");
			
			SyncModel.markedSection = null;
			
			var json : String = jsonLines.join("\n");
			GlobalEvents.events.export.json.emit({json: json});
			trace(json);
		}
		
		function onExportPanelExportCSV(e : Object) {
			var csvLines : Array = ['"{""type"":""handy""}",'];
			var startMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
			
			for (var iSection : int = 0; iSection < SyncModel.sections.length; iSection++) {
				var section : SyncSection = SyncModel.sections[iSection];
				var repeatCount : int = SyncModel.getNumberOfTimesToRepeatSection(iSection);
				var framesDelta : int = (section.lastFrame - section.firstFrame) + 1;
				
				for (var iRepeat : int = 0; iRepeat < repeatCount; iRepeat++) {
					var frameOffset : Number = framesDelta * iRepeat;
					
					for (var iFrame : int = 0; iFrame < section.positions.length; iFrame++) {
						var frameMiliseconds : int = SyncModel.getMilisecondsForFrame(frameOffset + section.positions[iFrame].frame - section.firstFrame);
						var csvMiliseconds : int = startMiliseconds[iSection] + frameMiliseconds;
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