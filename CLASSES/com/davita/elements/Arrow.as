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
	public class Arrow extends MovieClip
	{
		public var _myParent:MovieClip;
		
		public function Arrow()
		{	
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = (this.parent as MovieClip);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_myParent.stop();
		}
		
		public function goToAndClick(xPos:int, yPos:int, seconds:int):void 
		{
			TweenLite.to(this, seconds, {x:xPos, y:yPos, onComplete:playClick});
		}
		
		public function playClick():void 
		{
			this.play();
		}
	}
}