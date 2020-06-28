import Global.GlobalEvents;

import Models.AnimationModel;

class Controllers.ModifiersController {
	
	var animationContainer : MovieClip;
	var counter : Number = 0;
	
	function ModifiersController(_animationContainer : MovieClip) {
		animationContainer = _animationContainer;
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		var self = this;
		
		GlobalEvents.events.animation.frameUpdate.listen(function(e : Object) {
			self.counter++;
			for (var i : Number = 0; i < AnimationModel.modifiers.length; i++) {
				self.applyModifier(AnimationModel.modifiers[i]);
			}
		});
	}
	
	function applyModifier(modifier : Object) {
		if (modifier.every != undefined && counter % modifier.every != 0) {
			return;
		}
		
		if (modifier.when != undefined) {
			if (modifier.when.animation == "frame") {
				if (modifier.when.greaterThan != undefined && AnimationModel.currentFrame <= modifier.when.greaterThan) {
					return;
				}
				if (modifier.when.lessThan != undefined && AnimationModel.currentFrame >= modifier.when.lessThan) {
					return;
				}
			}
		}
		
		var offset : Number = 0;
		
		if (modifier.action == "increase") {
			offset = 1;
		}
		else if (modifier.action == "decrease") {
			offset = -1;
		}
		
		if (modifier.variable != undefined && animationContainer[modifier.variable] != undefined) {
			if (modifier.by != undefined) {
				animationContainer[modifier.variable] += modifier.by * offset;
			}
		}
	}
}