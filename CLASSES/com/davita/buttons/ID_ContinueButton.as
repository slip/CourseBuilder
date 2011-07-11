/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;

	public class ID_ContinueButton extends CourseButton
	{
		public var isEnabled:Boolean = new Boolean;
		public var _myParent:MovieClip;
		
		public function ID_ContinueButton()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
			addEventListener(MouseEvent.CLICK, clicked)
			_myParent = (this.parent as MovieClip);
		}

		function initialize(event:Event):void
		{
			this._myParent.stop();
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		function removed(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
		function clicked(event:MouseEvent):void
		{
			_myParent.play();
		}
		
	}
}