/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import fl.motion.easing.*;

	public class LessonEnded extends MovieClip
	{
		public var _myParent:MovieClip;
		
		public function LessonEnded()
		{
			_myParent = (this.parent as MovieClip);
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			
			if (_myParent)
			{
				_myParent.stop();
				_myParent.openGate();
			}
		}
		
		function initialize(event:Event):void
		{
			_myParent.stop();
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
		}		
	}
}