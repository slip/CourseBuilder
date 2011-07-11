// 
//  _DVA Duplicate And Offset.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2009-01-21.
//  Copyright 2009 normal design. All rights reserved.
// 



var doc = fl.getDocumentDOM();
var lib = fl.getDocumentDOM().library;
var selectedItems = fl.getDocumentDOM().selection;

function main() 
{	
	for (var i = selectedItems.length - 1; i >= 0; i--)
	{
		selectedItems[i].y = selectedItems[i].y + selectedItems[i].height + 15;
	};
}

main();