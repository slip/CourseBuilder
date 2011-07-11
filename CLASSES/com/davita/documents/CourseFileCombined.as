/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents
{
	import flash.display.*;
	import flash.events.*;
	import fl.motion.easing.*;
	import flash.text.*;
	
	import com.davita.events.Event;
	import com.davita.events.MouseEvent;
	import com.davita.buttons.ContinueButton;
	import com.davita.popups.GenericPopup;
	import com.davita.utilities.CBAnimator;
	import flash.media.SoundChannel;
	import com.davita.sound.*;

	/**
	 *  base class for davita standard course files.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public dynamic class CourseFileCombined extends CourseSwf
	{
		public var sndChannel:SoundChannel = new SoundChannel();
		
		/**
		 *	constructor
		 */
		public function CourseFileCombined()
		{			
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
				
		/**
		 *	this is needed to remove the popup instance created by swapping the z-index.
		 */
		private function removePopups():void 
		{
			for (var i:int = 0; i<this.numChildren; i++)
			{
				if (this.getChildAt(i) is GenericPopup) 
		        { 
		            this.removeChildAt(i);
		        }
			}
		}
		
		/* ================ */
		/* = clickHandler = */
		/* ================ */
		private function clickHandler(event:MouseEvent):void
		{
			if (event.target is ContinueButton)
			{
				removePopups();
				this.gotoAndPlay(this.currentFrame+1);
			}
			else
			{
				//trace("event.target: "+ event.target);
				//trace("event.target.name: "+ event.target.name);
			}
		}
	}
}
