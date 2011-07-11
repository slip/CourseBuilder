/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;

	public class CourseButton extends MovieClip
	{

		public function CourseButton()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);			
		}

		function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.buttonMode = true;
			this.tabEnabled = false;
			this.addEventListener(MouseEvent.ROLL_OVER, over);
			this.addEventListener(MouseEvent.ROLL_OUT, out);
			this.addEventListener(MouseEvent.CLICK, click)
		};

		function over(event:MouseEvent):void
		{
			this.filters=[new DropShadowFilter(0,45,0,.85,8,8,.7,BitmapFilterQuality.HIGH)];
		}
		
		function out(event:MouseEvent):void
		{
			this.filters=[];
		}
		
		function click(event:MouseEvent):void
		{
			/*this.buttonMode = false;
			this.enabled = false;*/
		}
	}
}