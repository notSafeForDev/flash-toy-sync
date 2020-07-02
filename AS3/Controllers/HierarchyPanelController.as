package Controllers {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import Global.GlobalEvents;
	import Debugging.Debug;
	import Types.ChildInfo;
	import Views.Panel;
	import Views.ScrollableArea;
	import Views.HierarchyField;

	public class HierarchyPanelController {
		
		var root : MovieClip;
		var animation : MovieClip;
		var hierarchyPanel : MovieClip;
		var hierarchyContent : MovieClip;
		
		var hierarchyFields : Vector.<HierarchyField> = new Vector.<HierarchyField>();
		var hierarchyFieldsVisible : Number = 0;
		var childSelected : MovieClip;
		
		function HierarchyPanelController(_root : MovieClip, _hierarchyPanel : MovieClip) {
			root = _root;
			hierarchyPanel = _hierarchyPanel;
			hierarchyContent = hierarchyPanel.ScrollableArea.Content;
			
			var panel : Panel = new Panel(hierarchyPanel, hierarchyPanel.ButtonMove, hierarchyPanel.ButtonMinimize);
			panel.bounds = new Rectangle(0, 0, 1280 - hierarchyPanel.width, 720 - 15);
			
			new ScrollableArea(hierarchyPanel.ScrollableArea.Handle, hierarchyPanel.ScrollableArea.Mask, hierarchyPanel.ScrollableArea.Content);
			
			GlobalEvents.events.animation.loaded.listen(function(e : Object) {
				animation = e.animation;
				childSelected = animation;
			});
			
			GlobalEvents.events.animation.frameUpdate.listen(onAnimationFrameUpdate);
		}
		
		function displayHierarchyField(_text : String, _child : MovieClip) {
			var hierarchyField : HierarchyField;
			
			if (hierarchyFieldsVisible + 1 >= hierarchyFields.length) {
				hierarchyField = new HierarchyField();
				hierarchyField.y = hierarchyFields.length * hierarchyField.height;
				
				var fieldIndex : Number = hierarchyFields.length;
				hierarchyField.addEventListener(MouseEvent.MOUSE_DOWN, function() {
					onHierarchyFieldClick(fieldIndex);
				});
				
				hierarchyFields.push(hierarchyField);
			}
			else {
				hierarchyField = hierarchyFields[hierarchyFieldsVisible];
			}
			
			hierarchyContent.addChild(hierarchyField);
			hierarchyField.textName.text = _text;
			hierarchyField.textFrame.text = _child.currentFrame + "/" + _child.totalFrames;
			hierarchyField.animationChild = _child;
			hierarchyFieldsVisible++;
		}
		
		function clearHierarchy() {
			hierarchyContent.removeChildren();
			hierarchyFieldsVisible = 0;
		}
		
		function getChildInfo(_object : MovieClip) : Vector.<ChildInfo> {
			return recursiveGetChildInfo(_object, new Vector.<ChildInfo>, new Vector.<String>);
		}
		
		function recursiveGetChildInfo(_object : MovieClip, _childInfo : Vector.<ChildInfo>, _path : Vector.<String>) : Vector.<ChildInfo> {
			for (var i = 0; i < _object.numChildren; i++) {
				var child : DisplayObject = _object.getChildAt(i);
				if (child is MovieClip) {
					_path.push(child.name);
					_childInfo.push(new ChildInfo(MovieClip(child), _path.slice()));
					recursiveGetChildInfo(MovieClip(child), _childInfo, _path);
					_path.pop();
				}
			}
			
			return _childInfo;
		}
		
		function onAnimationFrameUpdate(e : Object) {
			var i : int = 0;
			
			clearHierarchy();
			
			var childInfo : Vector.<ChildInfo> = getChildInfo(animation);
			
			displayHierarchyField("root", animation);
			
			for (i = 0; i < childInfo.length; i++) {
				if (childInfo[i].child.totalFrames == 1 && hasNestedAnimations(childInfo[i].child) == false) {
					continue;
				}
				
				var text : String = "";
				
				for (var iPath : int = 0; iPath < childInfo[i].path.length; iPath++) {
					if (iPath < childInfo[i].path.length - 1) {
						text += "    ";
					}
					else {
						text += childInfo[i].path[iPath];
					}
				}
				
				displayHierarchyField(text, childInfo[i].child);
			}
			
			for (i = 0; i < hierarchyFieldsVisible; i++) {
				hierarchyFields[i].highlight.visible = childSelected == hierarchyFields[i].animationChild;
			}
		}
		
		function onHierarchyFieldClick(_fieldIndex : Number) {
			childSelected = hierarchyFields[_fieldIndex].animationChild;
			GlobalEvents.events.hierarchyPanel.childSelected.emit({
				child: hierarchyFields[_fieldIndex].animationChild
			});
		}
		
		function getAllChildren(_parent : MovieClip) : Vector.<MovieClip> {
			var children : Vector.<MovieClip> = new Vector.<MovieClip>();
			
			for (var i = 0; i < _parent.numChildren; i++) {
				var child : DisplayObject = _parent.getChildAt(i);
				if (child is MovieClip) {
					var childMovieClip : MovieClip = MovieClip(child);
					children.push(childMovieClip);
					children = children.concat(getAllChildren(childMovieClip));
				}
			}
			
			return children;
		}
		
		function hasNestedAnimations(_parent : MovieClip) {
			var allChildren : Vector.<MovieClip> = getAllChildren(_parent);
			var hasChildrenMoreThanOneFrame : Boolean = false;
			
			for (var i : int = 0; i < allChildren.length; i++) {
				if (allChildren[i].totalFrames > 1) {
					hasChildrenMoreThanOneFrame = true;
					break;
				}
			}
			
			return hasChildrenMoreThanOneFrame;
		}
	}
}