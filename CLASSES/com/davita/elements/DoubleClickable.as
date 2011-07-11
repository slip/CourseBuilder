/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	
	/**
	 *  makes any element a double-click continue button.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  13.11.2007
	 */
	public class DoubleClickable extends Sprite
	{
		private var _myParent:MovieClip;
		
		public function DoubleClickable()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = (this.parent as MovieClip);
			this.doubleClickEnabled = true;	
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.DOUBLE_CLICK, doubleClicked);
			this._myParent.stop();
		}
		
		private function doubleClicked(Event:MouseEvent):void
		{
			removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClicked);
			this._myParent.play();
		}
	}
}