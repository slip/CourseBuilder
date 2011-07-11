var flashDoc = fl.getDocumentDOM();
var flashTimeline = flashDoc.getTimeline();
var currentFrame = flashTimeline.currentFrame;


if (flashDoc.selection.length > 0)
{

	// put the names of the selected mc's into an array, then sort.
	var selectedItems = fl.getDocumentDOM().selection;
	names = [];
	
	for (var i=0; i < selectedItems.length; i++) 
	{
		if (selectedItems[i].elementType == "instance") 
		{
			if (selectedItems[i].instanceType =="symbol") 
			{
				names.push(selectedItems[i].name);
			}
		}
	}
	
	names = names.sort();
	
	
	flashTimeline.setSelectedLayers(0);
	flashTimeline.setSelectedFrames(currentFrame, currentFrame, true);

	// get the actions on that frame, if there are any
	originalActions = fl.getDocumentDOM().getTimeline().layers[0].frames[currentFrame].actionScript;	

	// create a blank key frame in case there is no keyframe
	if (!originalActions == "") 
	{
		newActions = originalActions + "\n" + "animator.makeInvisible(" + names + ");\nanimator.fadeIn(.75, .5, " + names + ");";
	}
	else
	{
		newActions = "animator.makeInvisible(" + names + ");\nanimator.fadeIn(.75, .5, " + names + ");";
	}

	// put the new actions into the actions panel
	fl.getDocumentDOM().getTimeline().layers[0].frames[currentFrame].actionScript = newActions; 
}