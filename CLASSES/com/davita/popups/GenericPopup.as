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
	import com.davita.buttons.PopupButton;
	
	/**
	 *  GenericPopup builds
	 *	popups of different types.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  13.11.2007
	 */
	public class GenericPopup extends MovieClip
	{
		public var _originalX : int;
		public var _originalY : int;
		
		public function GenericPopup()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, dealloc);
		}
		
		private function init(event:Event):void
		{
			_originalX = this.x;
			_originalY = this.y;

			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			stop();
		}
		
		private function gotoPopup():void
		{
			parent.setChildIndex(this, parent.numChildren-1);
			this.alpha = 0;
			TweenLite.to(this, 1, {alpha:1});
			this.gotoAndStop(2);
			this.x = this.parent.x;
			this.y = this.parent.y;
		}

		private function returnFromPopup():void
		{
			this.alpha = 1;
			this.gotoAndStop(1);
			this.x = this._originalX;
			this.y = this._originalY;
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			if (event.target is PopupButton)
			{
				gotoPopup();
			}
			else if (event.target is CloseButton || event.target is FalconCloseBtn)
			{
				TweenLite.to(this, 1, {alpha:0, onComplete:returnFromPopup});
			}
			else
			{
				trace("event.target: "+ event.target);
				trace("event.target.name: "+ event.target.name);
			}
		}
		
		private function dealloc(event:Event):void 
		{
			/*trace("removed");*/
		}		
	}
}
