/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.quiz
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import fl.controls.*;
	import com.davita.elements.IKCheckBox;
	import com.davita.quiz.Quiz;
    import com.davita.quiz.BlankStandard;
	
	/**
	 *	base class for quiz items
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class QuizItem_FB extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		public static const ONE_TRY_MODE = 1;
		public static const TWO_TRIES_MODE = 2;
		
		public static const ANSWERED_CORRECTLY = 1;
		public static const ANSWERED_INCORRECTLY = 2;
		
		private var _parentQuiz:QuizCombined;
		private var _blanks : Array = new Array();
		private var _numOfRequiredLetters : int;
		private var _correctAnswers : int;
		private var _feedback:String;
		private var _positiveFeedbackArray:Array;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizItem_FB()
		{
			_correctAnswers = 0;
			_numOfRequiredLetters = -1;
			this.stop();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 *	setup
		 */
		private function init(event:Event):void 
		{
			setButtonText("Choose answer");
			checkAnswersBtn.enabled = false;
			setButtonText("Type answers");
			checkAnswersBtn.addEventListener(MouseEvent.CLICK, checkAnswersBtnClicked);
			_parentQuiz = (this.parent as QuizCombined);
		}

		/* ================================== */
		/* = adding answers to the quizItem = */
		/* ================================== */
		
		/**
		 *	Adds an answer to the QuizItem.
		 *	@usage
		 *	Add a correct answer:
		 *	<code>
		 *	addAnswer(blank1, "expected string");
		 *	</code>
		 *	@param answer: the answer as a string
		 *	@param blankName: set as correct answer if true; default is false
		 */
		public function addAnswer(blankName:BlankStandard, answer:String):void 
		{
			var newAnswer:Array = [blankName, answer];
			_blanks.push(newAnswer);
			blankName.isWaitingFor(answer);
		}
		
		public function setNumberOfRequiredLetters(num:int):void 
		{
			this._numOfRequiredLetters = num;
		}
		
		public function getNumberOfRequiredLetters():int 
		{
			return this._numOfRequiredLetters;
		}
		
		/* ============================================ */
		/* = methods related to checking the response = */
		/* ============================================ */

		/**
		 *	Checks to see if there are no answers checked.
		 *	@return
		 */
		private function checkForBadResponse():Boolean{
			return true;
		}
		
		public function correctAnswer():void 
		{
			this._correctAnswers++;
			if (this._correctAnswers == _blanks.length)
			{
				feedbackTxt.text = getPositiveFeedback();
				prepareToContinue();
			}
		}
		
		public function hint():void 
		{
			checkAnswersBtn.enabled = true;
			setButtonText("I give up");
		}
		
		/**
		 *	disables checkboxes and sets button label to 'Continue'
		 */
		private function prepareToContinue():void 
		{
			checkAnswersBtn.enabled = true;
			setButtonText("Continue");
		}

		/**
		 *	sends score to quiz
		 */
		private function sendCorrectToQuiz():void 
		{
			_parentQuiz.scoreAndContinue(ANSWERED_CORRECTLY);
		}
		
		private function sendIncorrectToQuiz():void 
		{
			_parentQuiz.scoreAndContinue(ANSWERED_INCORRECTLY);
		}
		
		/**
		 *	get positive feedback from the array
		 */
		private function getPositiveFeedback():String
		{
			return positiveFeedbackArray[Math.floor(Math.random() * _positiveFeedbackArray.length)];
		}

		/**
		 *	sets the label on the checkAnswerBtn
		 */
		private function setButtonText(buttonText:String):void{
			this.checkAnswersBtn.label = buttonText;
		}
		
		/**
		 *	handler for checkAnswersBtn
		 */
		private function checkAnswersBtnClicked(event:MouseEvent):void 
		{
			switch (checkAnswersBtn.label){
				case "I give up" :
					fillInTheBlanks();
				break;
				case "Proceed" :
					sendIncorrectToQuiz();
				break;
				case "Continue" :
					sendCorrectToQuiz();
				break;
			}
		}
		
		private function fillInTheBlanks():void 
		{
			for each (var blank:Array in _blanks)
			{
				var textField:BlankStandard = blank[0];
				var answer:String = blank[1];				
				textField.text = answer;
			}
			setButtonText("Proceed");
		}
		
		/* ================== */
		/* = Getter/Setters = */
		/* ================== */
		
		public function get feedback():String 
		{ 
			return _feedback; 
		}

		public function set feedback( value:String ):void 
		{
			if( value != _feedback ){
				_feedback = value;
				this.feedbackTxt.text = _feedback;
			}
		}
		
		public function get positiveFeedbackArray():Array 
		{ 
			return _positiveFeedbackArray; 
		}

		public function set positiveFeedbackArray( value:Array ):void 
		{
			if( value != _positiveFeedbackArray ){
				_positiveFeedbackArray = value;
			}
		}
	}
}
