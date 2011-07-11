/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;

	public class NextQuestionButton extends CourseButton
	{
		public var isEnabled:Boolean = new Boolean;
		
		public function NextQuestionButton()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
		}
	}
}