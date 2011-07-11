/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.events 
{
	import flash.events.*;
	
	/**
	 *	CourseEvent class
	 *	used by CourseWrapper
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author ian kennedy
	 *	@since  13.11.2007
	 */
	public class CourseEvent extends Event 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const PAGE_CHANGED:String = "pageChanged";
		public var pageNum:int;		
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function CourseEvent( type:String, pageNum:int, bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			this.pageNum = pageNum;
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public override function clone():Event 
		{
			return new CourseEvent(type, pageNum, bubbles, cancelable);
		}
		
		public override function toString():String
		{
            return formatToString("CourseEvent", "type", "pageNum", "bubbles", "cancelable", "eventPhase");
		};
		
	}
	
}
