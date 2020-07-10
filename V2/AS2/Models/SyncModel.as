import Core.MovieClipUtil;

import Types.SyncSection;

class Models.SyncModel {
	
	public static var fps : Number = -1;
	public static var animation : MovieClip;
	public static var childSelected : MovieClip;
	
	public static var markedSection : SyncSection;
	public static var sections : Array = [];
	
	public static function getInterpolatedPosition() : Number {
		var currentFrame : Number = MovieClipUtil.getCurrentFrame(childSelected);
		if (shouldReadFromMarkedSection() == true) {
			return markedSection.getInterpolatedPosition(currentFrame);
		}
		
		var sectionIndex : Number = getSectionIndexForChildSelected();
		if (sectionIndex >= 0) {
			var section : SyncSection = sections[sectionIndex];
			return section.getInterpolatedPosition(currentFrame);
		}
		
		return -1;
	}
	
	public static function hasPositionOnFrame() : Boolean {
		var currentFrame : Number = MovieClipUtil.getCurrentFrame(childSelected);
		if (shouldReadFromMarkedSection() == true) {
			return markedSection.getPositionIndexOnFrame(currentFrame) >= 0;
		}
		
		var sectionIndex : Number = getSectionIndexForChildSelected();
		if (sectionIndex >= 0) {
			var section : SyncSection = sections[sectionIndex];
			return section.getPositionIndexOnFrame(currentFrame) >= 0;
		}
		
		return false;
	}
	
	public static function getSectionIndexForChildSelected() : Number {
		for (var i : Number = 0; i < sections.length; i++) {
			var section : SyncSection = sections[i];
			var sectionChild : MovieClip = MovieClipUtil.getChildFromPath(animation, section.childPath);
			if (sectionChild == SyncModel.childSelected && canPlaySection(i) == true) {
				return i;
			}
		}
		
		return -1;
	}
	
	public static function getSectionIndexToPlay() : Number {
		for (var i : Number = 0; i < sections.length; i++) {
			if (canPlaySection(i) == true) {
				return i;
			}
		}
		
		return -1;
	}
	
	public static function canPlaySection(_index : Number) : Boolean {
		var section : SyncSection = sections[_index];
		var child : MovieClip = MovieClipUtil.getChildFromPath(animation, section.childPath);
		
		if (child == null || section.isFrameWithinSection(MovieClipUtil.getCurrentFrame(child)) == false) {
			return false;
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
					parent = MovieClipUtil.getChildFromPath(animation, pathToParent);
				}
				
				if (parent == null) {
					matchesActiveWhile = false;
					break;
				}
				
				var parentCurrentFrame : Number = MovieClipUtil.getCurrentFrame(parent);
				var parentTotalFrames : Number = MovieClipUtil.getTotalFrames(parent);
				
				if (section.activeWhile[key].frame != null && parentCurrentFrame != section.activeWhile[key].frame) {
					matchesActiveWhile = false;
				}
				if (section.activeWhile[key].from != null && parentCurrentFrame < section.activeWhile[key].from) {
					matchesActiveWhile = false;
				}
				if (section.activeWhile[key].to != null && parentCurrentFrame > section.activeWhile[key].to) {
					matchesActiveWhile = false;
				}
				if (section.activeWhile[key].total != null && parentTotalFrames != section.activeWhile[key].total) {
					matchesActiveWhile = false;
				}
			}
		}
		
		return matchesActiveWhile;
	}
	
	public static function getMilisecondsForFrame(_frame : Number) : Number {
		return Math.floor((_frame / fps) * 1000);
	}
	
	public static function getNumberOfTimesToRepeatSection(_sectionIndex : Number) : Number {
		var section : SyncSection = sections[_sectionIndex];
		var framesDelta : Number = section.lastFrame - section.firstFrame;
		var durationMiliseconds : Number = getMilisecondsForFrame(framesDelta);
		var minPlayDurationMiliseconds : Number = 3000;
		return Math.ceil(minPlayDurationMiliseconds / durationMiliseconds);
	}
	
	public static function getStartCSVMilisecondsForSections() : Array {
		var totalDurationMiliseconds : Number = 0;
		var milisecondsBetweenSections : Number = 1000;
		var miliseconds : Array = [];
		
		for (var i : Number = 0; i < sections.length; i++) {
			miliseconds.push(totalDurationMiliseconds);
			
			var section : SyncSection = sections[i];
			var framesDelta : Number = section.lastFrame - section.firstFrame;
			var repeatCount : Number = getNumberOfTimesToRepeatSection(i);
			
			totalDurationMiliseconds += milisecondsBetweenSections + getMilisecondsForFrame(framesDelta * repeatCount);
		}
		
		return miliseconds;
	}
	
	private static function shouldReadFromMarkedSection() : Boolean {
		if (markedSection == null) {
			return false;
		}
		if (MovieClipUtil.getChildFromPath(animation, markedSection.childPath) != childSelected) {
			return false;
		}
		if (markedSection.isFrameWithinSection(MovieClipUtil.getCurrentFrame(childSelected)) == false) {
			return false;
		}
		
		return true;
	}
}