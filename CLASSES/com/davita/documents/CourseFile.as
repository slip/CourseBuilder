/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import flash.text.*;
	
	import com.davita.events.*;
	import com.davita.buttons.*;

	/**
	 *  base class for davita standard course files.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public dynamic class CourseFile extends CourseSwf
	{
		/**
		 *	constructor
		 */
		public function CourseFile()
		{			
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/* ================ */
		/* = clickHandler = */
		/* ================ */
		private function clickHandler(event:MouseEvent):void
		{
			if (event.target is ContinueButton)
			{
				this.gotoAndPlay(this.currentFrame+1);
			}
			else if (event.target is CloseBtn)
			{
				event.target.parent.gotoAndStop(1);
				removeChild(event.target.parent);
			}
			else if (event.target is TownCrierBtn)
			{
				var townCrierPopup:TownCrierPopup = new TownCrierPopup();
				this.addChild(townCrierPopup);
			} 
			else if (event.target is DavitaWayBtn)
			{
				var davitaWayPopup:DavitaWayPopup = new DavitaWayPopup();
				this.addChild(davitaWayPopup);
			}
			else if (event.target is ThinkAboutBtn)
			{
				var thinkAboutPopup:ThinkAboutPopup = new ThinkAboutPopup();
				this.addChild(thinkAboutPopup);
			}
			else
			{
				//trace("event.target: "+ event.target);
				//trace("event.target.name: "+ event.target.name);
			}
		}
	}
}