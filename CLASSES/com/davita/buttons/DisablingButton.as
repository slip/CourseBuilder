/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons
{
	import flash.display.*;
	import flash.events.*;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import flash.filters.*;

	public class DisablingButton extends MovieClip
	{
		var thisParent:*;
		var thisIndex:int;
		var clicked:Boolean = new Boolean();
		
		public function DisablingButton()
		{
			this.buttonMode=true;
			this.tabEnabled = false;
			this.addEventListener(MouseEvent.CLICK, disableOthers);
			this.addEventListener(MouseEvent.ROLL_OVER,over);
			this.addEventListener(MouseEvent.ROLL_OUT,out);
			this.addEventListener(Event.ADDED,setParent);

		}

		function over(event:MouseEvent):void
		{
			this.filters=[new DropShadowFilter(0,45,0,.85,8,8,.7,BitmapFilterQuality.HIGH)];
		}

		function out(event:MouseEvent):void
		{
			this.filters=[];
		}

		function disableButton():void
		{
			this.alpha=.5;
			this.buttonMode = false;
			this.removeEventListener(MouseEvent.CLICK,disableOthers);
			this.removeEventListener(MouseEvent.ROLL_OVER,over);
			this.removeEventListener(MouseEvent.ROLL_OUT,out);
		}

		function enableButton():void
		{
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK,disableButton);
			this.addEventListener(MouseEvent.ROLL_OVER,over);
			this.addEventListener(MouseEvent.ROLL_OUT,out);
			this.alpha=1;
		}

		function disableOthers(event:MouseEvent):void
		{
			if (!clicked){
				for (var y:int=0; y < thisParent.buttons.length; y++)
				{
					if (y != thisIndex)
					{
						thisParent.buttons[y].disableButton();
					}
				}
				clicked = true;
			}
			else
			{
				enableOthers();
			}
			
		}


		function enableOthers():void
		{
			for (var z:int=0; z < thisParent.buttons.length; z++)
			{
				if (z != thisIndex)
				{
					thisParent.buttons[z].enableButton();
				}
			}
		}

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