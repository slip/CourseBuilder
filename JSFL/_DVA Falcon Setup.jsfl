// 
//  _DVA Falcon Setup
//  Commands
//  
//  Created by Ian Kennedy on 2010-09-16.
//  Copyright 2010 normal design. All rights reserved.
// 

// ==========================================================================================================
// = This command changes the background of the document to black and adds removeBackground to the actions. =
// ==========================================================================================================

var flashDoc = fl.getDocumentDOM();
var flashTimeline = flashDoc.getTimeline();

flashDoc.backgroundColor = '#000000';

// get the actions on that frame, if there are any
originalActions = fl.getDocumentDOM().getTimeline().layers[0].frames[0].actionScript;	

// paste the sound insert on top of the actions
newActions = "removeBackground();\n" + originalActions;

// put the new actions into the actions panel
fl.getDocumentDOM().getTimeline().layers[0].frames[0].actionScript = newActions; 
