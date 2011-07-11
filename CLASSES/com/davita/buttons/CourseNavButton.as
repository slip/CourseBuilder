/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;

	public class CourseNavButton extends MovieClip
	{
		private var thisParent:*;
		public var thisIndex:int;
		public var isEnabled:Boolean = new Boolean;
		
		public function CourseNavButton()
		{
			isEnabled = true;
			this.buttonMode = true;
			this.tabEnabled = false;
			this.addEventListener(MouseEvent.ROLL_OVER, over);
			this.addEventListener(MouseEvent.ROLL_OUT, out);
			this.addEventListener(Event.ADDED, setParent);

		}

		function over(event:MouseEvent):void
		{
			this.filters=[new DropShadowFilter(0,45,0,.85,8,8,.7,BitmapFilterQuality.HIGH)];
		}
		
		function out(event:MouseEvent):void
		{
			this.filters=[];
		}
		
		public function disableButton():void
		{
			this.isEnabled = false;
			this.alpha = .5;
			this.buttonMode = false;
			this.removeEventListener(MouseEvent.ROLL_OVER, over);
			this.removeEventListener(MouseEvent.ROLL_OUT, out);
		};
		
		public function enableButton():void
		{
			this.isEnabled = true;
			this.alpha = 1;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.ROLL_OVER, over);
			this.addEventListener(MouseEvent.ROLL_OUT, out);
			this.gotoAndStop(1);
		};

		function setParent(event:Event):void
		{
			if (this.parent is ButtonSet)
			{
				thisParent=ButtonSet(this.parent);
				for (var w:int=0; w < thisParent.buttons.length; w++)
				{
					if (this == thisParent.buttons[w])
					{
						thisIndex=w;
					}
				}
			}
		}

	}
}