/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.games {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;

	/**
	 *	Developed for the IATA course, this class relies on a graphic ReviewBackground.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  27.08.2008
	 */

	public class QuizGameReview extends MovieClip {
		
		private var reviewLoader:Loader = new Loader();
		private var reviewBackground:ReviewBackground = new ReviewBackground();
		private var reviewPage:String;
		
		/**
		 *	@Constructor
		 */
		public function QuizGameReview(review:String){
			super();
 			this.reviewPage = review;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function openGate(){
			if (this.parent.parent)
			{
				this.parent.parent.openGate();
			}
		}
		
		private function init(event:Event):void
		{
			reviewLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, reviewLoaderErrorHandler);
			reviewLoader.contentLoaderInfo.addEventListener(Event.INIT, reviewLoaderInitListener);
						
			reviewBackground.x = -100;
			reviewBackground.y = -100;
			addChild(reviewBackground);
			addChild(reviewLoader);
			reviewLoader.load(new URLRequest(reviewPage));
		}
		
		private function reviewLoaderErrorHandler(event:IOErrorEvent):void 
		{
			trace(event);
			reviewLoader.load(new URLRequest("coursefiles/"+this.reviewPage));
		}
		
		private function reviewLoaderInitListener(e:Event):void
		{
			reviewLoader.y = -50;
			
			reviewLoader.content.width = 800;
			reviewLoader.content.height = 480;
		}		
	}
}
