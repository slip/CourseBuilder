// 
//  _DVA Add Arrow
//  Commands
//  
//  Created by Ian Kennedy on 2010-09-16.
//  Copyright 2010 normal design. All rights reserved.
// 

// ================================================================================================
// = This command adds an arrow from the library to the stage and the corresponding actionscript. =
// ================================================================================================

doc = fl.getDocumentDOM();
library = doc.library;
var flashTimeline = doc.getTimeline();
var currentFrame = flashTimeline.currentFrame;
var theInput;

if (library.itemExists('BUTTONS_ETC/arrowMC')) 
{
	theInput = prompt("Move arrow to\nEnter x, y, time").replace(/^\s+|\s+$/g, "");
	// add the arrow to the stage
	library.addItemToDocument({x:500, y:300},'BUTTONS_ETC/arrowMC');
	
	// name the arrow instance
	doc.selection[0].name = "arrow_mc";
	
	// set up the actions
	flashTimeline.setSelectedLayers(0);
	flashTimeline.setSelectedFrames(currentFrame, currentFrame, true);	

	// get the actions on that frame, if there are any
	originalActions = fl.getDocumentDOM().getTimeline().layers[0].frames[currentFrame].actionScript;	

	// create a blank key frame in case there is no keyframe
	if (!originalActions == "")
	{
		newActions = originalActions + "\n" + "arrow_mc.goToAndClick(" + theInput + ");";
	}
	else
	{
		newActions = "arrow_mc.goToAndClick(x, y, time);";
	}

	// put the new actions into the actions panel
	fl.getDocumentDOM().getTimeline().layers[0].frames[currentFrame].actionScript = newActions; 
	
}
 else { alert("The arrow does not exist at BUTTONS_ETC/arrowMC. Did you move it? Huh? Did ya?"); }
