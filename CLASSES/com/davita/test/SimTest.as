/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.test
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.getQualifiedClassName;
	import flash.external.*;
	import flash.text.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.davita.documents.CourseSwf;

	/**
	 *base class for post test
	 *
	 *@langversion ActionScript 3.0
	 *@playerversion Flash 9.0
	 *
	 *@author Ian Kennedy
	 *@since  15.11.2007
	 */
	public class SimTest extends CourseSwf
	
	{

		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		private var numOfQuestionsAnsweredCorrectly:Number;
		private var numOfQuestionsAnsweredIncorrectly:Number;

		private var passingScore:Number;
		private var tries:Number = 0;
		private var indicator:MovieClip;
		
		public var myParent:MovieClip;

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *@Constructor
		 */
		public function SimTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(event:Event):void
		{
			if (this.parent.parent != null)
			{
				myParent = parent.parent as MovieClip;
			}
			// initial values
			numOfQuestionsAnsweredCorrectly = 0;
			numOfQuestionsAnsweredIncorrectly = 0;

			// event listeners
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function markAndContinue(correct:Boolean):void
		{
			tries = 0;
			if (correct)
			{
				indicator = new CorrectIndicator();
				numOfQuestionsAnsweredCorrectly++;
			}
			
			else 
			{
				indicator = new IncorrectIndicator();
				numOfQuestionsAnsweredIncorrectly++;
			}
			
			this.addChildAt(indicator,this.numChildren-1);
			indicator.x = 0;
			indicator.y = 0;
			indicator.alpha = 0;
			var myTimeline:TimelineLite = new TimelineLite({onComplete:timeLineComplete});
			myTimeline.append(new TweenLite(indicator, 1, {alpha:1}));
			myTimeline.append(new TweenLite(indicator, 1, {alpha:0}));
		}
		
		private function timeLineComplete():void
		{
			this.removeChild(indicator);
			this.play();
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			if (!getQualifiedClassName(event.target))
			{
				;// do nothing
			}
			else
			{
				switch (getQualifiedClassName(event.target))
				{
					case "IncorrectButton" :
						tries++;
						trace("tries: " + tries);
						if (tries >= 2)
						{
							markAndContinue(false);
						}
						break;

					case "CorrectBtn01" :
						markAndContinue(true);
						break;

					case "CorrectBtn02" :
						markAndContinue(true);
						break;

					case "ContinueBtn" :
						tries = 0;
						this.play();
						break;

					case "FalconContinueBtn" :
						tries = 0;
						this.play();
						break;

					default :
						trace("other thing clicked: " + getQualifiedClassName(event.target));
				}
			}
		}
	}
}