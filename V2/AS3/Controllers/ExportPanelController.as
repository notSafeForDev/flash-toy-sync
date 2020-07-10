package Controllers {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import Core.*;
	
	import Global.GlobalEvents;

	public class ExportPanelController {
		
		var defaultOutputString : String = "OUTPUT...";
		
		var textOutput : TextField;
		
		function ExportPanelController(_panelContainer : MovieClip) {
			textOutput = _panelContainer.Content.TextOutput;
			
			new UIDragableWindow(_panelContainer, _panelContainer.ButtonMove);
			
			var buttonExportJSON : UIButton = new UIButton(_panelContainer.Content.ButtonExportJSON);
			var buttonExportCSV : UIButton = new UIButton(_panelContainer.Content.ButtonExportCSV);
			
			buttonExportJSON.onMouseDown = onButtonExportJSONMouseDown;
			buttonExportCSV.onMouseDown = onButtonExportCSVMouseDown;
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.positionPanel.marked.listen(onPositionPanelMarked);
			GlobalEvents.events.export.json.listen(onExportJSON);
			GlobalEvents.events.export.csv.listen(onExportCSV);
		}
		
		function onButtonExportJSONMouseDown() {
			GlobalEvents.events.exportPanel.json.emit();
		}
		
		function onButtonExportCSVMouseDown() {
			GlobalEvents.events.exportPanel.csv.emit();
		}
		
		function onPositionPanelMarked(e : Object) {
			textOutput.text = defaultOutputString;
		}
		
		function onExportJSON(e : Object) {
			textOutput.text = e.json;
		}
		
		function onExportCSV(e : Object) {
			textOutput.text = e.csv;
		}
	}
}