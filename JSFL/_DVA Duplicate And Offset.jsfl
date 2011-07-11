// 
//  _DVA Duplicate and Offset
//  Commands
//  
//  Created by Ian Kennedy on 2009-01-21.
//  Copyright 2009 normal design. All rights reserved.
// 



doc = fl.getDocumentDOM();
lib = fl.getDocumentDOM().library;

var item;
var selectedItems;
var originalLibraryName;
var originalInstanceName;
var newName;

function main() 
{	
    fl.getDocumentDOM().library.selectNone();
	selectedItems = fl.getDocumentDOM().selection;

	// check for a selection
	if (checkForOneSelectedItem()) 
	{
		item = selectedItems[0];
		originalInstanceName = item.name;
		originalLibraryName = item.libraryItem.name;
        
        newName = prompt("Name the symbol:\nOld Name: " + item.libraryItem.name).replace(/^\s+|\s+$/g,"");
        if (newName == "" || newName.length == 0 || newName == null) {
           alert("You have to enter a new name!");
           return;
        }
        
        if (newName == originalLibraryName) {
            alert("You have to enter a unique name");
            return;    
        }

		// make sure it is a mc
		if (item.instanceType == "symbol") 
		{	
			if (duplicateLibraryItem())
            {
                duplicateInstance();
            }
		}	
	}
}

function duplicateLibraryItem() 
{
	if (lib.duplicateItem(originalLibraryName)) 
	{
        lib.setItemProperty("name", newName);
        return true;
	}
    return false;
}

function duplicateInstance() 
{
    fl.getDocumentDOM().duplicateSelection();
    var newInstance = fl.getDocumentDOM().selection[0];
    newInstance.y = newInstance.y + newInstance.height + 15;

	newLibItem = lib.getSelectedItems()[0];
	fl.getDocumentDOM().selection[0].libraryItem = newLibItem;
    fl.getDocumentDOM().selection[0].name = newName + "_mc";
}


function checkForOneSelectedItem() 
{
	if (selectedItems.length < 1) 
	{
		alert("This command requires you to select a MovieClip on the stage.");
		return false;
	}
	else if (selectedItems.length > 1) 
	{
		alert("This command requires you to select just one MovieClip on the stage.");
		return false;
	}
	else
	{
		return true;
	}
}


main();
