/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.popups
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import com.davita.events.*;
	
	/**
	 *  The ClosedCaption class is used within a DaVita CourseWrapper
	 *	to display closed captions of audio (if any) playing in the
	 *	currently loaded CourseFile.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  13.11.2007
	 */
	public class ClosedCaption extends MovieClip
	{	
		public var isVisible:Boolean = new Boolean();
		private var ccText:String;
		public var closedCaption_txt:TextField = new TextField();
		private var ccFormat:TextFormat = new TextFormat();

		public function ClosedCaption()
		{
			this.visible = false;
			isVisible = false;

			// set position on the stage
			this.x = 20;
			this.y = 600;

			// set formatting
			ccFormat.font = "Gotham Medium";
			ccFormat.size = 12;
			ccFormat.color = 0xFFFFFF;

			closedCaption_txt.width = 920;
			closedCaption_txt.height = 55;
			closedCaption_txt.x = 20;
			closedCaption_txt.y = 10;
			closedCaption_txt.wordWrap = true;
			closedCaption_txt.embedFonts = true;
			closedCaption_txt.antiAliasType = AntiAliasType.ADVANCED;

			addChild(closedCaption_txt);
			closedCaption_txt.setTextFormat(ccFormat);
			closedCaption_txt.defaultTextFormat = ccFormat;
		}

		public function getCcText():String
		{ 
			return ccText; 
		}

		public function setCcText(value:String):void 
		{
			if( value != ccText ){
				ccText = value;
				closedCaption_txt.text = ccText;
			}
		}
		
		public function updateCaption(event:CaptionEvent):void
		{
		    setCcText(event.captionText);
		};
		
		public function showCC():void
		{
			this.visible = true;
			isVisible = true;
		};
		
		public function hideCC():void
		{
			this.visible = false
			isVisible = false;
		};
		
		
		
	}
}