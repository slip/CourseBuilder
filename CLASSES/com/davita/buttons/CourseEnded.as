/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;

	public class CourseEnded extends MovieClip
	{
		public var _myParent:MovieClip;
		
		public function CourseEnded()
		{
			_myParent = (this.parent as MovieClip);
			_myParent.stop();
			
			if (this.parent._myParent)
			{
				this.parent._myParent.LMSSetComplete();
                // debug begin
                var debugAlertText = "CourseEnded button working hard!";
                AlertManager.createAlert(this, debugAlertText);
                // debug end
			}
		}
	}
}
