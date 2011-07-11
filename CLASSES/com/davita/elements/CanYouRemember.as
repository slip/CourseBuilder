/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import fl.controls.*;
	import com.davita.elements.CYRTextEntry;
	
	/**
	 *  CanYouRemember is a multiple choice quiz
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  20.11.2007
	 */
	public class CanYouRemember extends MovieClip
	{
		private var _blanks : Array = new Array();
		private var _numOfRequiredLetters : int;
		private var _correctAnswers : int;
		private var _myParent:MovieClip;
		public var correctAnswerFeedback:String = "";
		public var neededHintFeedback:String = "";
		
		/**
		 *	@constructor
		 */
		public function CanYouRemember()
		{
			fillInTheBlanksBtn.addEventListener(MouseEvent.CLICK, fillInTheBlanks);
			_correctAnswers = 0;
			_numOfRequiredLetters = -1;
			_myParent = (this.parent as MovieClip);
			_myParent.stop();
			this.stop();
		}
		
		public function correctAnswer():void 
		{
			this._correctAnswers++;
			if (this._correctAnswers == _blanks.length)
			{
				feedbackTxt.text = correctAnswerFeedback;
				play();
			}
		}
		
		public function hint():void 
		{
			// nothing - Quiz.as uses the hint from CYRTextEntry
		}
		
		public function setNumberOfRequiredLetters(num:int):void 
		{
			this._numOfRequiredLetters = num;
		}
		
		public function getNumberOfRequiredLetters():int 
		{
			return this._numOfRequiredLetters;
		}
		
		/**
		 *	@public
		 *	takes two arguments, a CYRTextEntry instance name, and an answer in the form of a string
		 *	used to push an answer onto an array
		 */
		public function addAnswer(blankName:CYRTextEntry, answer:String):void 
		{
			var newAnswer:Array = [blankName, answer];
			_blanks.push(newAnswer);
			blankName.isWaitingFor(answer);
		}
		
		private function fillInTheBlanks(event:MouseEvent):void 
		{
			for each (var blank:Array in _blanks)
			{
				var textField:CYRTextEntry = blank[0];
				var answer:String = blank[1];				
				textField.text = answer;
			}
			feedbackTxt.text = neededHintFeedback;
			play();
		}
	}
}