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
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	import com.davita.utilities.*;
	import com.davita.documents.*;
	
	/**
	 *  Review class provides the review panel
	 *	with review functionality.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  19.11.2007
	 */
	public class Review extends MovieClip
	{
		private var reviewFormat:TextFormat = new TextFormat();	
		private var reviewIntroTxt:TextField = new TextField();
		
		/**
		 *	@constructor
		 */
		public function Review()
		{
			// TODO: move this.y to coursewrapper
			this.y = 60;

			setUpTextFields();
			review_btn.addEventListener(MouseEvent.CLICK, hideReview)
		}

		private function hideReview(event:MouseEvent):void
		{
			(this.parent as MovieClip).hideReview();
		};

		/**
		 *	sets up the text fields and adds them to the stage
		 */
		private function setUpTextFields():void {
			var textFieldX:int = 146;

			reviewFormat.font = "Gotham Medium";
			reviewFormat.size = 12;
			reviewFormat.leading = 5;
			reviewFormat.color = 0x000000;

			reviewIntroTxt.defaultTextFormat = reviewFormat;
			reviewIntroTxt.text = "Welcome to the course review page. We've made every effort to make these courses as easy to review as your refrigerator.";
			reviewIntroTxt.x = textFieldX;
			reviewIntroTxt.y = 112;
			reviewIntroTxt.width = 400;
			reviewIntroTxt.multiline = true;
			reviewIntroTxt.wordWrap = true;
			reviewIntroTxt.autoSize = TextFieldAutoSize.LEFT;
			reviewIntroTxt.embedFonts = true;
			reviewIntroTxt.antiAliasType = AntiAliasType.ADVANCED;
			

			addChild(reviewIntroTxt);
		}

		/**
		 *	sends the pagenum to CourseWrapper.reviewLoadPage(pagenum)
		 *	triggered by a clicked link in reviewResultsTxt
		 */
		private function handleLink(event:TextEvent):void 
		{
			var linkContent:Array = event.text.split(",");
			if (linkContent[1] != null)
			{
				(this.parent as MovieClip).reviewLoadPage(linkContent[1]);
			}
		}
	}
}
