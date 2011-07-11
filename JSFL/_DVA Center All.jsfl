// 
//  _DVA Center All.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2009-01-22.
//  Copyright 2009 normal design. All rights reserved.
// 

doc = fl.getDocumentDOM();

doc.selectAll();
doc.align("left", false);
doc.group();
doc.align("horizontal center", true);
doc.align("vertical center", true);
doc.unGroup();
doc.selectAll();