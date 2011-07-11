/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	
	public class ButtonSet extends MovieClip {
		public var buttons:Array;

		public function ButtonSet() {

		}
		
		public function addButtons(buttonSet:Array):void 
		{
			buttons = buttonSet;

			for (var i:int = 0; i < buttons.length; i++) 
			{
				addChild(buttons[i]);
			}
		}
	}
}