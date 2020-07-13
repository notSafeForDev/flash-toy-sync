import Models.SyncModel;
	
import Types.SyncSection;
	
import Global.GlobalEvents;

class Controllers.ExportController {
	
	function ExportController() {
		GlobalEvents.events.exportPanel.exportJSON.listen(this, onExportPanelExportJSON);
		GlobalEvents.events.exportPanel.refreshJSON.listen(this, onExportPanelRefreshJSON);
		GlobalEvents.events.exportPanel.exportCSV.listen(this, onExportPanelExportCSV);
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
	
	function onExportPanelRefreshJSON(e : Object) {
	
	}
	
	function onExportPanelExportCSV(e : Object) {
		var csvLines : Array = ['"{""type"":""handy""}",'];
		var startMiliseconds : Array = SyncModel.getStartCSVMilisecondsForSections();
		
		for (var iSection : Number = 0; iSection < SyncModel.sections.length; iSection++) {
			var section : SyncSection = SyncModel.sections[iSection];
			var repeatCount : Number = SyncModel.getNumberOfTimesToRepeatSection(iSection);
			
			for (var iRepeat : Number = 0; iRepeat < repeatCount; iRepeat++) {
				var frameOffset : Number = section.framesDelta * iRepeat;
				
				for (var iFrame : Number = 0; iFrame < section.positions.length; iFrame++) {
					var frameMiliseconds : Number = SyncModel.getMilisecondsForFrame(frameOffset + section.positions[iFrame].frame - section.firstFrame);
					var csvMiliseconds : Number = startMiliseconds[iSection] + frameMiliseconds;
					csvLines.push(csvMiliseconds + "," + section.positions[iFrame].position);
				}
			}
		}
		
		var csv : String = csvLines.join("\n");
		GlobalEvents.events.export.csv.emit({csv: csv});
		trace(csv);
	}
}