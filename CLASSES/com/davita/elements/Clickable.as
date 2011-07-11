/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	
	/**
	 *  Makes any element a continue button.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  13.11.2007
	 */
	public class Clickable extends Sprite
	{
		private var _myParent:MovieClip;
		
		public function Clickable()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = (this.parent as MovieClip);			
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.CLICK, clicked);
			this._myParent.stop();
			this.buttonMode = true;
		}
		
		private function clicked(Event:MouseEvent):void
		{
			removeEventListener(MouseEvent.CLICK, clicked);
			this._myParent.play();
		}
	}
}