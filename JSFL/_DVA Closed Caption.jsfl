// 
//  _DVA Closed Caption.jsfl
//  Commands
//  
//  Created by Ian Kennedy on 2009-01-21.
//  Copyright 2009 normal design. All rights reserved.
// 

timeline = fl.getDocumentDOM().getTimeline();

timeline.insertKeyframe(timeline.currentFrame);
var originalText = timeline.getFrameProperty("actionscript", 0, 0);
if (originalText == undefined) 
{
	originalText = "";
};
var newText = originalText + "\nthis.hasAudio = true;\nsetCcText(\"replace this\");";
timeline.setFrameProperty("actionScript", newText);
