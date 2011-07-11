// 
//  _DVA Add Sound
//  Commands
//  
//  Created by Ian Kennedy on 2010-09-16.
//  Copyright 2010 normal design. All rights reserved.
// 

// ======================================================================================================
// = This command takes a selected sound from the library, asks for a name, then adds it to the actions =
// ======================================================================================================

var flashDoc = fl.getDocumentDOM();
var lib = fl.getDocumentDOM().library;
var flashTimeline = flashDoc.getTimeline();

var libItems = lib.getSelectedItems();

if (libItems < 1 || libItems > 1)
{
	alert("Select one sound object from the library.");
}

else
{
	var newName;
	for (var i=0; i < libItems.length; i++) 
	{
		if (libItems[i].itemType == "sound") 
		{
			newName = prompt("Name the sound: (Snd01)").replace(/^\s+|\s+$/g, "");
			lowerName = newName.toLowerCase();
			libItems[i].linkageExportForAS = true;
			libItems[i].linkageExportInFirstFrame = true;
			libItems[i].linkageExportForRS = false;
			libItems[i].name = newName;
			libItems[i].linkageClassName = newName;
			libItems[i].compressionType = "Default";
			// libItems[i].bitRate = "128 kbps";
			// libItems[i].quality = "Best";
			
			// select the actions on the first frame and add the sound like so:
			// var snd02 = new Snd02();
			flashTimeline.setSelectedLayers(0);
			flashTimeline.setSelectedFrames(0, 0, true);

			// get the actions on that frame, if there are any
			originalActions = fl.getDocumentDOM().getTimeline().layers[0].frames[0].actionScript;	

			// paste the sound insert on top of the actions
			if (!originalActions == "") 
			{
				newActions = "var " + lowerName + " = new " + newName + "();\n" + originalActions;
			}
			else
			{
				newActions = "\n" + "var " + lowerName + " = new " + newName + "();";
			}

			// put the new actions into the actions panel
			fl.getDocumentDOM().getTimeline().layers[0].frames[0].actionScript = newActions; 
			
		}
	}
}