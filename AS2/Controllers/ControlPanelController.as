import Global.GlobalEvents;

import Models.AnimationModel;

class Controllers.ControlPanelController {
	
	var container : MovieClip;
	
	var buttonPlay : Button;
	var buttonStop : Button;
	var buttonStepBackwards : Button;
	var buttonStepForwards : Button;
	var buttonExportPositions : Button;
	var buttonExportCSV : Button;
	
	var lastPlayedFrame : Number = -1;
	var loopFirstFrame : Number = -1;
	var loopLastFrame : Number = -1;
	
	function ControlPanelController(_container : MovieClip) {
		var self = this;
		
		container = _container;
		container._visible = false;
		
		buttonPlay = container.ButtonPlay;
		buttonStop = container.ButtonStop;
		buttonStepBackwards = container.ButtonStepBackwards;
		buttonStepForwards = container.ButtonStepForwards;
		buttonExportPositions = container.ButtonExportPositions;
		buttonExportCSV = container.ButtonExportCSV;
		
		container.ButtonExportPositions.TextType.text = "JSON";
		container.ButtonExportCSV.TextType.text = "CSV";
		
		buttonPlay._visible = false;
		
		buttonPlay.onRelease = function() {
			self.showPlayButton(false);
			GlobalEvents.events.controlPanel.play.emit();
		}
		buttonStop.onRelease = function() {
			self.showPlayButton(true);
			GlobalEvents.events.controlPanel.stop.emit();
		}
		buttonStepBackwards.onRelease = function() {
			self.showPlayButton(true);
			GlobalEvents.events.controlPanel.stepBackwards.emit();
		}
		buttonStepForwards.onRelease = function() {
			self.showPlayButton(true);
			GlobalEvents.events.controlPanel.stepForwards.emit();
		}
		buttonExportPositions.onRelease = function() {
			GlobalEvents.events.controlPanel.exportPositions.emit();
		}
		buttonExportCSV.onRelease = function() {
			GlobalEvents.events.controlPanel.exportCSV.emit();
		}
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		var self = this;
		
		GlobalEvents.events.userConfig.loaded.listen(function(e : Object) {
			GlobalEvents.events.animation.loaded.listen(function() {
				self.container._visible = e.config.editorEnabled;
			});
		});
		
		GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
			self.container.TextFrame.text = "Frame: " + e.frame;
			self.container.TextLoopFirstFrame.text = "Loop first frame: " + AnimationModel.sectionStartFrame;
			self.container.TextLoopLastFrame.text = "Loop last frame: " + AnimationModel.sectionLastFrame;
		});
		
		GlobalEvents.events.animation.forceStopped.listen(function() {
			self.showPlayButton(true);
		});
		GlobalEvents.events.animation.resumed.listen(function() {
			self.showPlayButton(false);
		});
		
		GlobalEvents.events.export.json.listen(function(e : Object) {
			self.container.TextOutput.text = e.json;
		});
		GlobalEvents.events.export.csv.listen(function(e : Object) {
			self.container.TextOutput.text = e.csv;
		});
	}
	
	function showPlayButton(_state : Boolean) {
		buttonPlay._visible = _state;
		buttonStop._visible = !_state;
	}
}