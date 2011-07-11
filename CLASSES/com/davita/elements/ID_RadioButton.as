/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	import fl.motion.easing.*;
	
	/**
	 *  PopupFactory creates and returns
	 *	popups of different types.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  13.11.2007
	 */
	public class ID_RadioButton extends MovieClip
	{
		public function ID_RadioButton()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stop();
			addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		private function handleClick(e:MouseEvent):void
		{
			this.gotoAndStop(2);
			this.enabled = false;
			removeEventListener(MouseEvent.CLICK, handleClick);
		}
	}
}