import Core.*;

import Models.AnimationModel;

import Global.GlobalEvents;

class Controllers.HierarchyPanelController {
	
	var list : UIList;
	
	var textPath : TextField;
	
	var fieldChildren : Array;
	
	function HierarchyPanelController(_panelContainer : MovieClip) {
		textPath = _panelContainer.Content.TextPath;
		
		new UIDragableWindow(_panelContainer, _panelContainer.ButtonMove);
		new UIScrollArea(_panelContainer.Content.Content, _panelContainer.Content.Mask, _panelContainer.Content.Handle); 
		
		list = new UIList(_panelContainer.Content.Content, "HierarchyField");
		
		list.isElementsSelectable = true;
		list.onElementSelected = FunctionUtil.bind(this, onListElementSelected);
		
		addGlobalEventListeners();
	}
	
	function addGlobalEventListeners() {
		GlobalEvents.events.frame.update.listen(this, onFrameUpdate);
	}
	
	function onFrameUpdate(e : Object) {
		if (AnimationModel.animation == null) {
			return;
		}
		
		var pathToChildSelected : Array = MovieClipUtil.getChildPath(AnimationModel.animation, AnimationModel.childSelected);
		if (pathToChildSelected == null) {
			textPath.text = "-";
		}
		else if (pathToChildSelected.length == 0) {
			textPath.text = "[]";
		}
		else {
			textPath.text = '["' + pathToChildSelected.join('", "') + '"]';
		}
		
		list.clearElements();
		fieldChildren = [];
		
		var children : Array = MovieClipUtil.getNestedChildren(AnimationModel.animation);			
		children.unshift(AnimationModel.animation);
		
		for (var i : Number = 0; i < children.length; i++) {
			var currentFrame : Number = MovieClipUtil.getCurrentFrame(children[i]);
			var totalFrames : Number = MovieClipUtil.getTotalFrames(children[i]);
			
			if (totalFrames == 1 && MovieClipUtil.hasNestedAnimations(children[i]) == false) {
				continue;
			}
			
			var path : Array = MovieClipUtil.getChildPath(AnimationModel.animation, children[i]);
			var element : MovieClip = list.addElement();
			
			var fieldName : String = "";
			while (fieldName.length < (path.length - 1) * 4) {
				fieldName += " ";
			}
			
			if (path.length > 0) {
				fieldName += path[path.length - 1];
			}
			else {
				fieldName = "root";
			}
			
			element.TextName.mouseEnabled = false;
			element.TextName.text = fieldName;
			
			element.TextFrame.mouseEnabled = false;
			element.TextFrame.text = currentFrame + "/" + totalFrames;
			
			MovieClipUtil.setVisible(element.Highlight, children[i] == AnimationModel.childSelected);
			
			fieldChildren.push(children[i]);
		}
	}
	
	function onListElementSelected(_fieldIndex : Number) {
		GlobalEvents.events.hierarchyPanel.childSelected.emit({child: fieldChildren[_fieldIndex]});
	}
}