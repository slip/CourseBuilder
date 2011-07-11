// 
//  _DVA Bulletize Text.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2009-07-30.
//  Copyright 2009 normal design. All rights reserved.
// 

doc = fl.getDocumentDOM();
library = doc.library;

moveText();
placeBullet();

function moveText() 
{
	// select the text on the screen and move it to x:15, y:0
	doc.selectAll();
	doc.moveSelectionBy({x:15,y:0})
}

function placeBullet() 
{
	// select the bullet if it exists
	if (library.itemExists('.GRAPHICS/Bullet')) 
	{
		library.selectItem('.GRAPHICS/Bullet');
		library.addItemToDocument({x:7, y:7},'.GRAPHICS/Bullet');
	}
    else { alert("The bullet does not exist at .GRAPHICS/Bullet. Did you move it? Huh? Did ya?"); }
}
