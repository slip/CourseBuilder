// 
//  _DVA Set to Lossless.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2009-01-21.
//  Copyright 2009 normal design. All rights reserved.
// 


var lib = fl.getDocumentDOM().library;
var libItems = lib.getSelectedItems();

if (libItems < 1) 
{
	alert("Select bitmaps from the Library to change to lossless.");
}

else
{
	for (var i=0; i < libItems.length; i++) 
	{
		if (libItems[i].itemType == "bitmap") 
		{
			libItems[i].compressionType = "lossless";
			libItems[i].allowSmoothing = false;
		}
	}
}