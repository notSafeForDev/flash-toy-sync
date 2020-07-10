import Controllers.AnimationController;
/* import Controllers.HierarchyPanelController;
import Controllers.PlayControlsPanelController;
import Controllers.PositionPanelController;
import Controllers.ExportPanelController; */

class Index {
	
	function Index(_root : MovieClip) {
		new AnimationController(_root.AnimationContainer);
		/* new HierarchyPanelController(_root.HierarchyPanelContainer);
		new PlayControlsPanelController(_root.PlayControlsPanelContainer);
		new PositionPanelController(_root.PositionPanelContainer);
		new ExportPanelController(_root.ExportPanelContainer); */
	}
}