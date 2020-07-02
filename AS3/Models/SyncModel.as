package Models {
	
	import flash.display.MovieClip;
	
	import Types.SyncSection;
	
	public class SyncModel {
		
		public static var fps : int = -1;
		public static var childSelected : MovieClip;
		public static var markedSection : SyncSection;
		public static var sections : Vector.<SyncSection> = new Vector.<SyncSection>();
		
		public static function getPositionOnFrame(_frame : int) : Number {
			if (markedSection != null && markedSection.isForChild(childSelected) == true) {
				return markedSection.getPositionOnFrame(_frame);
			}
			
			var index : int = getSectionIndexOnFrame(_frame);
			if (index >= 0 && sections[index].isForChild(childSelected) == true) {
				return sections[index].getPositionOnFrame(_frame);
			}
			
			return -1;
		}
		
		public static function getInterpolatedPositionOnFrame(_frame : int) : Number {
			if (markedSection != null && markedSection.isForChild(childSelected) == true && markedSection.isFrameWithinSection(_frame) == true) {
				return markedSection.getInterpolatedPosition(_frame);
			}
			
			var index : int = getSectionIndexOnFrame(_frame);
			if (index >= 0) {
				return sections[index].getInterpolatedPosition(_frame);
			}
			
			return -1;
		}
		
		public static function hasPositionOnFrame(_frame : int) : Boolean {
			if (markedSection != null && markedSection.isForChild(childSelected) == true && markedSection.isFrameWithinSection(_frame) == true) {
				return markedSection.hasPositionOnFrame(_frame);
			}
			
			var index : int = getSectionIndexOnFrame(_frame);
			if (index >= 0) {
				return sections[index].hasPositionOnFrame(_frame);
			}
			
			return false;
		}
		
		public static function getSectionIndexOnFrame(_frame : int) : int {
			for (var i : int = 0; i < sections.length; i++) {
				if (sections[i].isForChild(childSelected) == true && sections[i].isFrameWithinSection(_frame) == true) {
					return i;
				}
			}
			
			return -1;
		}
		
		public static function getMilisecondsForFrame(_frame : Number) : int {
			return Math.floor((_frame / fps) * 1000);
		}
		
		public static function getNumberOfTimesToRepeatSection(_sectionIndex : int) : int {
			var section : SyncSection = sections[_sectionIndex];
			var framesDelta : int = section.lastFrame - section.firstFrame;
			var durationMiliseconds : int = getMilisecondsForFrame(framesDelta);
			var minPlayDurationMiliseconds : int = 3000;
			return Math.ceil(minPlayDurationMiliseconds / durationMiliseconds);
		}
		
		public static function getStartCSVMilisecondsForSections() : Array {
			var milisecondsAtStart : int = 20000;
			var totalDurationMiliseconds : int = milisecondsAtStart;
			var milisecondsBetweenSections : int = 1000;
			var miliseconds : Array = [];
			
			for (var i : int = 0; i < sections.length; i++) {
				miliseconds.push(totalDurationMiliseconds);
				
				var section : SyncSection = sections[i];
				var framesDelta : int = section.lastFrame - section.firstFrame;
				var repeatSection : int = getNumberOfTimesToRepeatSection(i);
				
				totalDurationMiliseconds += milisecondsBetweenSections + getMilisecondsForFrame(framesDelta * repeatSection);
			}
			
			return miliseconds;
		}
	}
}