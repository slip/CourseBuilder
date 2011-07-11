/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/

package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;

	public class IKCheckBox extends MovieClip
	{
		public var isSelected:Boolean = new Boolean;
		
		public function IKCheckBox()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			enable();
		}
		
		private function over(event:MouseEvent):void
		{
			this.gotoAndStop("over");
		}
		
		private function out(event:MouseEvent):void
		{
			if (!this.isSelected)
			{
				this.gotoAndStop("up");
			} else 
			{
				this.gotoAndStop("down");
			}
		}
		
		private function click(event:MouseEvent):void
		{
			if (!this.isSelected)
			{
				this.gotoAndStop("down");
				this.isSelected = true;
			} else 
			{
				this.gotoAndStop("up");
				this.isSelected = false;
			}
		}
		
		public function enable():void
		{
			this.isSelected = false;
			this.addEventListener(MouseEvent.ROLL_OVER, over);
			this.addEventListener(MouseEvent.ROLL_OUT, out);
			this.addEventListener(MouseEvent.CLICK, click);
			this.gotoAndStop("up");		
		}
		
		public function disable():void
		{
			this.isSelected = true;
			this.removeEventListener(MouseEvent.ROLL_OVER, over);
			this.removeEventListener(MouseEvent.ROLL_OUT, out);
			this.removeEventListener(MouseEvent.CLICK, click);
		}
	}
}