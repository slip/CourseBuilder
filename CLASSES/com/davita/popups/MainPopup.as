/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.popups
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
	public class MainPopup extends MovieClip
	{
		public function MainPopup()
		{	
			this.alpha = 0;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, dealloc);
		}
		
		private function init(event:Event):void
		{
			TweenLite.to(this, 2, {alpha:1});
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function dealloc(event:Event):void 
		{
			
		}
	}
}