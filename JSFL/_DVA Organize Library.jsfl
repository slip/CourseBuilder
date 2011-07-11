// 
//  _DVA Organize Library.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2010-09-21.
//  Copyright 2010 normal design. All rights reserved.
// 

LibraryOrganizer = function()
{
	
}

var proto = LibraryOrganizer.prototype;
proto.doc = fl.getDocumentDOM();

proto.init = function()
{
	
	if (!this.doc) 
	{
		alert("You need to open a Flash document.");
	}
	
	else
	{	
		this.lib = this.doc.library;
		
		// select none and create a folder at the root
		this.lib.selectNone();
		var folders = [".ORGANIZER", ".ORGANIZER/buttons", ".ORGANIZER/sounds", ".ORGANIZER/bitmaps", ".ORGANIZER/graphics", ".ORGANIZER/movieclips"];
		
		for (var i=0; i < folders.length; i++) 
		{
			if (! this.lib.itemExists(folders[i])) 
			{
				this.lib.newFolder(folders[i]);
			}
		};
		
		// select all items and get to work sorting them
		this.lib.selectAll();
		
		var allItems = this.lib.getSelectedItems();
		var itemsLength = allItems.length;
		
		var rootItems = new Array();
		
		// iterate through all items and put root items into rootItems array
		for (var i = allItems.length - 1; i >= 0; i--)
		{
			var itemName = allItems[i].name;
			var itemType = this.lib.getItemType(itemName);
			
			// make sure we're only dealing with root items
			if (itemName.search(/\//i) == -1) 
			{
				if (itemType != "folder" && itemType != "undefined" && itemType != null) 
				{
					rootItems.push(allItems[i]);
				}
			}
		}
		
		// now we should have only root items
		// run through them and put them where they belong
		fl.trace("Cleanup time, you messy sod. I'll be putting the following things where they belong:\n");
		
		for (var i=0; i < rootItems.length; i++) 
		{
			fl.trace(rootItems[i].itemType + " : " + rootItems[i].name);
			
			if (rootItems[i].itemType == "bitmap") 
			{
				this.lib.moveToFolder(".ORGANIZER/bitmaps", rootItems[i].name, false);
			}
			
			if (rootItems[i].itemType == "sound") 
			{
				this.lib.moveToFolder(".ORGANIZER/sounds", rootItems[i].name, false);
			}
			
			if (rootItems[i].itemType == "graphic") 
			{
				this.lib.moveToFolder(".ORGANIZER/graphics", rootItems[i].name, false);
			}
			
			if (rootItems[i].itemType == "movie clip") 
			{
				this.lib.moveToFolder(".ORGANIZER/movieclips", rootItems[i].name, false);
			}
			
			if (rootItems[i].itemType == "button") 
			{
				this.lib.moveToFolder(".ORGANIZER/buttons", rootItems[i].name, false);
			}
		}
		
		this.lib.selectNone();
	}
}

var obj = new LibraryOrganizer();
obj.init();