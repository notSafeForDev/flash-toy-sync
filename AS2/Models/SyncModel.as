import Utils.ObjectUtil;
import Utils.MathUtil;

class Models.SyncModel {
	
	static var markedPositions : Array = [];
	static var sections : Array = [];
	static var sectionMaxRepeatCount = 3;
	static var fps : Number = -1;
	
	static function markPosition(_position : Number, _frame : Number) {
		_position = Math.min(100, _position);
		_position = Math.max(0, _position);
		
		var sectionIndex : Number = getSectionIndexForFrame(_frame);
		
		if (sectionIndex >= 0) {
			copyPositionsFromSectionToMarkedPositions(sectionIndex);
			sections.splice(sectionIndex, 1);
			trace("splice section: " + sectionIndex);
		}
		
		var markedPositionIndex : Number = getMarkedPositionIndexOnFrame(_frame);
		
		if (markedPositionIndex >= 0) {
			markedPositions.splice(markedPositionIndex, 1);
		}
		
		markedPositions.push({frame: _frame, position: _position});
		sortMarkedPositions();
	}
	
	static function removePositionAtFrame(_frame : Number) {
		var markedPositionIndex : Number = getMarkedPositionIndexOnFrame(_frame);
		if (markedPositionIndex >= 0) {
			markedPositions.splice(markedPositionIndex, 1);
			return;
		}
		
		var sectionIndex : Number = getSectionIndexForFrame(_frame);
		if (sectionIndex >= 0) {
			copyPositionsFromSectionToMarkedPositions(sectionIndex);
			sections.splice(sectionIndex, 1);
			trace("splice section: " + sectionIndex);
			var markedPositionIndex : Number = getMarkedPositionIndexOnFrame(_frame);
			if (markedPositionIndex >= 0) {
				markedPositions.splice(markedPositionIndex, 1);
			}
			
			sortMarkedPositions();
		}
	}
	
	static function addSectionFromMarkedPositions() {
		var data : Object = {};
		for (var i : Number = 0; i < SyncModel.markedPositions.length; i++) {
			data[SyncModel.markedPositions[i].frame] = SyncModel.markedPositions[i].position;
			
			var sectionIndex : Number = getSectionIndexForFrame(SyncModel.markedPositions[i].frame);
			if (sectionIndex >= 0) {
				sections.splice(sectionIndex, 1);
				trace("splice section: " + sectionIndex);
			}
		}
		
		sections.push(data);
		sortSections();
	}
	
	static function getMarkedPositionIndexOnFrame(_frame : Number) : Number {
		for (var i : Number = 0; i < markedPositions.length; i++) {
			if (markedPositions[i].frame == _frame) {
				return i;
			}
		}
		
		return -1;
	}
	
	static function getPositionOnFrame(_frame : Number) : Number {
		for (var i : Number = 0; i < markedPositions.length; i++) {
			if (markedPositions[i].frame == _frame) {
				return markedPositions[i].position;
			}
		}
		
		for (var i : Number = 0; i < sections.length; i++) {
			for (var key : String in sections[i]) {
				if (parseFloat(key) == _frame) {
					return sections[i][key];
				}
			}
		}
		
		return -1;
	}
	
	static function getInterpolatedPositionAtFrame(_frame : Number) : Number {
		var sectionIndex : Number = getSectionIndexForFrame(_frame);
		var isFrameAtMarkedPositions : Boolean = markedPositions.length > 0 && _frame >= markedPositions[0].frame && _frame <= markedPositions[markedPositions.length - 1].frame;
		
		if (isFrameAtMarkedPositions == true) {
			if (markedPositions.length == 1) {
				return markedPositions[0].position;
			}
			
			for (var i : Number = 0; i < markedPositions.length - 1; i++) {
				var markedBefore : Object = markedPositions[i];
				var markedAfter : Object = markedPositions[i + 1];
				var percentageBetweenFrames : Number = MathUtil.getPercentage(_frame, markedBefore.frame, markedAfter.frame);
				if (percentageBetweenFrames >= 0 && percentageBetweenFrames <= 1) {
					return MathUtil.lerp(markedBefore.position, markedAfter.position, percentageBetweenFrames);
				}
			}
		} 
		else if (sectionIndex >= 0) {
			var section : Object = sections[sectionIndex];
			var keys : Array = ObjectUtil.getKeys(section);
			if (keys.length == 1) {
				return section[keys[0]];
			}
			
			for (var i : Number = 0; i < keys.length - 1; i++) {
				var percentageBetweenFrames : Number = MathUtil.getPercentage(_frame, parseFloat(keys[i]), parseFloat(keys[i + 1]));
				var positionBefore : Number = section[keys[i]];
				var positionAfter : Number = section[keys[i + 1]];
				if (percentageBetweenFrames >= 0 && percentageBetweenFrames <= 1) {
					return MathUtil.lerp(positionBefore, positionAfter, percentageBetweenFrames);
				}
			}
			return -1;
		}
		
		return -1;
	}
	
	static function hasPositionOnFrame(_frame : Number) : Boolean {
		// getPositionOnFrame >= 0 should not be used, as -1 can be used for both when there's no position and when it's supposed to be stopped
		
		for (var i : Number = 0; i < markedPositions.length; i++) {
			if (markedPositions[i].frame == _frame) {
				return true;
			}
		}
		
		for (var i : Number = 0; i < sections.length; i++) {
			for (var key : String in sections[i]) {
				if (parseFloat(key) == _frame) {
					return true;
				}
			}
		}
		
		return false;
	}
	
	static function sortMarkedPositions() {
		markedPositions.sort(function(a : Object, b : Object) {
			return a.frame - b.frame;
		});
	}
	
	static function sortSections() {
		sections.sort(function(a : Object, b : Object) {
			var sectionKeysA : Array = ObjectUtil.getKeys(a);
			var sectionKeysB : Array = ObjectUtil.getKeys(b);
			return parseFloat(sectionKeysA[0]) - parseFloat(sectionKeysB[0]);
		});
	}
	
	static function isStartOfSectionAtFrame(_frame : Number) : Boolean {
		for (var i : Number = 0; i < sections.length; i++) {
			var keys : Array = ObjectUtil.getKeys(sections[i]);
			
			// We use the last key as the keys are reversed, probably due to JSON.parse
			if (parseFloat(keys[keys.length - 1]) == _frame) {
				return true;
			}
		}
		
		return false;
	}
	
	static function getSectionIndexForFrame(_frame : Number) : Number {
		for (var i : Number = 0; i < sections.length; i++) {
			var keys : Array = ObjectUtil.getKeys(sections[i]);
			// We use the last key as the keys are reversed, probably due to JSON.parse
			var firstFrame : Number = parseFloat(keys[keys.length - 1]);
			var lastFrame : Number = parseFloat(keys[0]);
			
			if (_frame >= firstFrame && _frame <= lastFrame) {
				return i;
			}
		}
		
		return -1;
	}
	
	static function getStartFrameForSection(_index : Number) : Number {
		if (_index < 0 || _index >= sections.length) {
			return -1;
		}
		
		var keys : Array = ObjectUtil.getKeys(sections[_index]);
		// We use the last key as the keys are reversed, probably due to JSON.parse
		var firstFrame : Number = parseFloat(keys[keys.length - 1]);
		return firstFrame;
	}
	
	static function getIdForFrame(_frame : Number) : String {
		return Math.floor(_frame / 10).toString();
	}
	
	// Not used, but kept just in case
	static function getCSVMiliseconds(_firstFrame : Number, _miliseconds : Number, _milisecondsEnd) : Number {
		var id : String = getIdForFrame(_firstFrame);
		return parseFloat(id + padStartOfValue(_miliseconds, _milisecondsEnd.toString().length));
	}
	
	static function getCSVMiliseconds2(_sectionIndex : Number, _frame : Number) : Number {
		var firstFrame : Number = getStartFrameForSection(_sectionIndex);
		var startMiliseconds = (firstFrame / fps) * 1000;
		var startCSVMiliseconds = startMiliseconds * sectionMaxRepeatCount;
		var miliseconds = (_frame / fps) * 1000;
		
		return Math.floor(startCSVMiliseconds + (miliseconds - startMiliseconds));
	}
	
	static function getFramesInSection(_sectionIndex : Number) : Array {
		var frames : Array = [];
		for (var key : String in sections[_sectionIndex]) {
			frames.push(parseFloat(key));
		}
		
		frames.reverse(); // We reverse the array as the keys are reversed in the section, probaby due to JSON.parse
		return frames;
	}
	
	static function getPositionsInSection(_sectionIndex : Number) : Array {
		var positions : Array = [];
		for (var key : String in sections[_sectionIndex]) {
			positions.push(sections[_sectionIndex][key]);
		}
		
		positions.reverse(); // We reverse the array as the keys are reversed in the section, probaby due to JSON.parse
		return positions;
	}
	
	static function copyPositionsFromSectionToMarkedPositions(_sectionIndex : Number) {
		var section : Object = sections[_sectionIndex];
		for (var key : String in section) {
			markedPositions.push({
				frame: parseFloat(key),
				position: section[key]
			});
		}
	}
	
	static function padStartOfValue(_value : Number, _length : Number) : String {
		var valueString : String = _value.toString();
		while (valueString.length < _length) {
			valueString = "0" + valueString;
		}
		return valueString;
	}
}