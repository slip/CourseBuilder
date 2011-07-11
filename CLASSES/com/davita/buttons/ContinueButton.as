/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	/*import com.greensock.TweenLite;*/

	public class ContinueButton extends CourseButton
	{
		public var isEnabled:Boolean = new Boolean;
		public var _myParent:MovieClip;
		
		public function ContinueButton()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			_myParent = (this.parent as MovieClip);
			/*this.alpha = 0;*/
		}

		function initialize(event:Event):void
		{
			_myParent.stop();
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			/*TweenLite.to(this, 1, {alpha:1});*/
		}		
	}
}