import Core.*;
	
import Global.GlobalEvents;

class Controllers.ExportPanelController {
	
	var defaultOutputString : String = "OUTPUT...";
	
	var textOutput : TextField;
	
	function ExportPanelController(_panelContainer : MovieClip) {
		textOutput = _panelContainer.Content.TextOutput;
		
		new UIDragableWindow(_panelContainer, _panelContainer.ButtonMove);
		
		var buttonExportJSON : UIButton = new UIButton(_panelContainer.Content.ButtonExportJSON);
		// var buttonRefreshJSON : UIButton = new UIButton(_panelContainer.Content.ButtonRefreshJSON);
		var buttonExportCSV : UIButton = new UIButton(_panelContainer.Content.ButtonExportCSV);
		
		buttonExportJSON.onMouseDown = FunctionUtil.bind(this, onButtonExportJSONMouseDown);
		// buttonRefreshJSON.onMouseDown = FunctionUtil.bind(this, onButtonRefreshJSONMouseDown);
		buttonExportCSV.onMouseDown = FunctionUtil.bind(this, onButtonExportCSVMouseDown);
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		GlobalEvents.events.positionPanel.marked.listen(this, onPositionPanelMarked);
		GlobalEvents.events.export.json.listen(this, onExportJSON);
		GlobalEvents.events.export.csv.listen(this, onExportCSV);
	}
	
	function onButtonExportJSONMouseDown() {
		GlobalEvents.events.exportPanel.exportJSON.emit();
	}
	
	function onButtonRefreshJSONMouseDown() {
		GlobalEvents.events.exportPanel.refreshJSON.emit();
	}
	
	function onButtonExportCSVMouseDown() {
		GlobalEvents.events.exportPanel.exportCSV.emit();
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