package Controllers {
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import Views.Panel;
	import Global.GlobalEvents;
	
	public class ExportPanelController {
		
		var buttonExportJSON : DisplayObject;
		var buttonExportCSV : DisplayObject;
		
		var textOutput : TextField;
		var defaultOutput : String = "OUTPUT...";
		
		function ExportPanelController(_root : MovieClip, _panelContainer : MovieClip) {
			var panel : Panel = new Panel(_panelContainer, _panelContainer.ButtonMove, _panelContainer.ButtonMinimize);
			panel.bounds = new Rectangle(0, 0, 1280 - _panelContainer.width, 720 - 15);
			
			buttonExportJSON = _panelContainer.Content.ButtonExportJSON;
			buttonExportCSV = _panelContainer.Content.ButtonExportCSV;
			
			textOutput = _panelContainer.Content.TextOutput;
			textOutput.text = defaultOutput;
			
			buttonExportJSON.addEventListener(MouseEvent.CLICK, onButtonExportJSONClick);
			buttonExportCSV.addEventListener(MouseEvent.CLICK, onButtonExportCSVClick);
			
			addGlobalEventListeners();
		}
		
		function addGlobalEventListeners() {
			GlobalEvents.events.export.json.listen(function(e : Object) {
				textOutput.text = e.json;
				textOutput.scrollV = 0;
			});
			
			GlobalEvents.events.export.csv.listen(function(e : Object) {
				textOutput.text = e.csv;
				textOutput.scrollV = 0;
			});
			
			GlobalEvents.events.export.clear.listen(function() {
				textOutput.text = defaultOutput;
				textOutput.scrollV = 0;
			});
		}
		
		function onButtonExportJSONClick(e : MouseEvent) {
			GlobalEvents.events.exportPanel.json.emit();
		}
		
		function onButtonExportCSVClick(e : MouseEvent) {
			GlobalEvents.events.exportPanel.csv.emit();
		}
	}
}