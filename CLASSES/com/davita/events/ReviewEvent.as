/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.events 
{
	import flash.events.*;
	
	/**
	 *	ReviewEvent class
	 *	used by CourseFile to dispatch a
	 *	reviewChanged event and send the
	 *	new review text.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author ian kennedy
	 *	@since  13.11.2007
	 */
	public class ReviewEvent extends Event 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const REVIEW_CHANGED:String = "reviewChanged";
		public var reviewInfo:Array;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function ReviewEvent( type:String, reviewInfo:Array, bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			this.reviewInfo = reviewInfo;
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public override function clone():Event 
		{
			return new ReviewEvent(type, reviewInfo, bubbles, cancelable);
		}
		
		public override function toString():String
		{
            return formatToString("reviewEvent", "type", "reviewInfo", "bubbles", "cancelable", "eventPhase");
		};
		
	}
	
}
