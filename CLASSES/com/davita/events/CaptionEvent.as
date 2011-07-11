/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.events 
{
	import flash.events.*;
	
	/**
	 *	CaptionEvent class
	 *	used by CourseFile to dispatch a
	 *	captionChanged event and send the
	 *	new caption text.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author ian kennedy
	 *	@since  13.11.2007
	 */
	public class CaptionEvent extends Event 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const CAPTION_CHANGED:String = "captionChanged";
		public var captionText:String;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function CaptionEvent( type:String, captionText:String, bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			this.captionText = captionText;
			/*trace("captionChanged: " + captionText);*/
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public override function clone():Event 
		{
			return new CaptionEvent(type, captionText, bubbles, cancelable);
		}
		
		public override function toString():String
		{
            return formatToString("CaptionEvent", "type", "captionText", "bubbles", "cancelable", "eventPhase");
		};
		
	}
	
}
