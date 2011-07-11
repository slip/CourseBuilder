/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenLite;
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
	public class RollOverInfo extends MovieClip
	{
		public function RollOverInfo()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			this.stop();
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}
		
		private function handleRollOver(e:MouseEvent):void
		{
			this.gotoAndStop(2);
		}
		
		private function handleRollOut(e:MouseEvent):void
		{
			this.gotoAndStop(1);
		}
	}
}