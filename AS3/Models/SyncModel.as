package Models {
	
	import flash.display.MovieClip;
	
	import Types.SyncSection;
	
	public class SyncModel {
		
		public static var fps : int = -1;
		public static var animation : MovieClip;
		public static var childSelected : MovieClip;
		public static var markedSection : SyncSection;
		public static var markedSectionInsertIndex : int = -1;
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
			
			var index : int = getCurrentSectionIndex();
			if (index >= 0 && sections[index].isForChild(childSelected) == true) {
				return sections[index].getInterpolatedPosition(_frame);
			}
			
			return -1;
		}
		
		public static function hasPositionOnFrame(_frame : int) : Boolean {
			if (markedSection != null && markedSection.isForChild(childSelected) == true && markedSection.isFrameWithinSection(_frame) == true) {
				return markedSection.hasPositionOnFrame(_frame);
			}
			
			var index : int = getCurrentSectionIndex();
			if (index >= 0 && sections[index].isForChild(childSelected) == true) {
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
			var totalDurationMiliseconds : int = 0;
			var milisecondsBetweenSections : int = 1000;
			var miliseconds : Array = [];
			
			for (var i : int = 0; i < sections.length; i++) {
				miliseconds.push(totalDurationMiliseconds);
				
				var section : SyncSection = sections[i];
				var framesDelta : int = (section.lastFrame - section.firstFrame) + 1;
				var repeatSection : int = getNumberOfTimesToRepeatSection(i);
				
				totalDurationMiliseconds += milisecondsBetweenSections + getMilisecondsForFrame(framesDelta * repeatSection);
			}
			
			return miliseconds;
		}
		
		public static function getCurrentSectionIndex() : int {
			if (animation == null) {
				return -1;
			}
			
			for (var i : int = 0; i < sections.length; i++) {
				var section : SyncSection = sections[i];
				var child : MovieClip = SyncSection.getChildFromPath(animation, section.childPath);
				
				if (child == null || section.isFrameWithinSection(child.currentFrame) == false) {
					continue;
				}
				
				var matchesActiveWhile : Boolean = true;
				if (section.activeWhile != null) {
					for (var key : String in section.activeWhile) {
						var parent : MovieClip;
						if (key == "root") {
							parent = animation;
						}
						else {
							var pathToParent : Array = section.childPath.slice(0, section.childPath.indexOf(key) + 1);
							parent = SyncSection.getChildFromPath(animation, pathToParent);
						}
						
						if (parent == null || parent.currentFrame < section.activeWhile[key].from || parent.currentFrame > section.activeWhile[key].to) {
							matchesActiveWhile = false;
							break;
						}
					}
				}
				
				if (matchesActiveWhile == true) {
					return i;
				}
			}
			
			return -1;
		}
	}
}