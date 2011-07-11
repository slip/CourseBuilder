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
	
	/**
	 *	base class for quiz items
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class QuizItem_MC extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		public static const ONE_TRY_MODE = 1;
		public static const TWO_TRIES_MODE = 2;
		
		public static const ANSWERED_CORRECTLY = 1;
		public static const ANSWERED_INCORRECTLY = 2;
		
		private var _parentQuiz:QuizCombined;
		private var _question:String;
		private var _answers:Array = new Array();
		private var _feedback:String;
		private var _negativeFeedback:String;
		private var _positiveFeedbackArray:Array;
		private var _numOfAnswers:int;
		private var _correctAnswer:int;
		private var _tries:int;
		private var _answeredCorrectly;
		private var _allowedTries;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizItem_MC()
		{
			_numOfAnswers = 0;
			_correctAnswer = 0;
			_tries = 0;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 *	setup
		 */
		private function init(event:Event):void 
		{
			hideAllAnswers();
			setupTextFields();
			setButtonText("Choose answer");
			checkAnswersBtn.enabled = false;
			checkAnswersBtn.addEventListener(MouseEvent.CLICK, checkAnswersBtnClicked);
			_parentQuiz = (this.parent as QuizCombined);
		}
		
		/**
		 *	sets one or two allowed tries based on the number of answers
		 */
		private function setMode():void 
		{
			_numOfAnswers <= 2 ?  _allowedTries = QuizItem_MC.ONE_TRY_MODE : _allowedTries = QuizItem_MC.TWO_TRIES_MODE;
		}

		/* ================================== */
		/* = adding answers to the quizItem = */
		/* ================================== */
		
		/**
		 *	Adds an answer to the QuizItem.
		 *	@usage
		 *	Add a correct answer:
		 *	<code>
		 *	addAnswer("The Correct Answer", true);
		 *	</code>
		 *	Add an incorrect answer:
		 *	<code>
		 *	addAnswer("An Incorrect Answer", false);
		 *	</code>
		 *	@param answer: the answer as a string
		 *	@param isCorrectAnswer: set as correct answer if true; default is false
		 */
		public function addAnswer(answer:String, isCorrectAnswer:Boolean = false):void 
		{
			// make the answers visible as they are added
			this["check"+_numOfAnswers].visible = true;
			this["answerMark"+_numOfAnswers].visible = true;
			this["answerText"+_numOfAnswers].visible = true;
			
			// add the answer to the array and add a listener to the checkbox
			this._answers[_numOfAnswers] = answer;
			this["answerText"+_numOfAnswers].text = answer;
			this["check"+_numOfAnswers].addEventListener(MouseEvent.CLICK, checkBoxClicked);
			if (isCorrectAnswer)
			{
				_correctAnswer = _numOfAnswers;
			}
			this._numOfAnswers++;
			setMode();
		}
		
		public function trueFalse(question:String, answer:Boolean):void
		{
			this.question = question;
			if(answer)
			{
				this.addAnswer("True", true);
				this.addAnswer("False", false);
			} else {
				this.addAnswer("True", false);
				this.addAnswer("False", true);
			}
		}
		/* ============================================ */
		/* = methods related to checking the response = */
		/* ============================================ */

		/**
		 *	Checks to see if there are no answers checked.
		 *	@return
		 */
		private function checkForBadResponse():Boolean{
			// no boxes checked
			if (numberOfBoxesChecked() == 0)
			{
				this.feedback = "Please enter an answer.";
				return true;
			}
			// too many boxes checked
			if (numberOfBoxesChecked() > 1)
			{
				this.feedback = "Please enter only one answer.";
				return true;
			}
			return false;			
		}
		
		/**
		 *	check answer
		 */
		private function checkAnswer():void 
		{
			if (getSelectedCheckboxNumber() == _correctAnswer) {
				correctAnswerHandler();
			}
			else {
				incorrectAnswerHandler();
			}
		}
		
		/**
		 *	correct answer function
		 */
		private function correctAnswerHandler():void 
		{
			_answeredCorrectly = ANSWERED_CORRECTLY;
			disableCheckBoxes();
			this.feedback = getPositiveFeedback();
			prepareToContinue();
		}
		
		/**
		 *	checks # of tries and # of allowed tries
		 */
		private function incorrectAnswerHandler():void 
		{
			switch (_tries){
				// first try
				case 0 :
					if (_allowedTries == ONE_TRY_MODE)
					{
						_answeredCorrectly = ANSWERED_INCORRECTLY;
						if (this._negativeFeedback)
						{
							this.feedback = this._negativeFeedback;
						}
						else
						{
							this.feedback = "Sorry, that is incorrect. The correct answer is: " + _answers[_correctAnswer] + ".";							
						}
						prepareToContinue();
					} 
					else if (_allowedTries == TWO_TRIES_MODE) 
					{
						_tries++;
						resetCheckBoxes();
						this.feedback = "Sorry, that is incorrect.";							
						setButtonText("Try Again");
						checkAnswersBtn.enabled = false;
					}
				break;
				// second try
				case 1 :
					_answeredCorrectly = ANSWERED_INCORRECTLY;
                    if (this._negativeFeedback)
						{
							this.feedback = this._negativeFeedback;
						}
						else
						{
							this.feedback = "Sorry, that is incorrect. The correct answer is: " + _answers[_correctAnswer] + ".";							
						}
                    
					prepareToContinue();
				break;
			}
		}
		
		/**
		 *	disables checkboxes and sets button label to 'Continue'
		 */
		private function prepareToContinue():void 
		{
			disableCheckBoxes();
			setButtonText("Continue");
		}
		
		/**
		 *	returns the number of the selected checkbox
		 */
		private function getSelectedCheckboxNumber():int 
		{
			var selected:int;
			for ( var i:int = 0; i < _answers.length; i++ ) {
				var checkbox = this["check"+i];
				if (checkbox.isSelected) {
					selected = i;
				}
			}
			return selected;
		}
		
		/**
		 *	returns the number of checkboxes selected
		 */
		private function numberOfBoxesChecked():int 
		{
			var numChecked:int = 0;

			for ( var i:int = 0; i < _answers.length; i++ ) {
				var checkbox = this["check"+i];
				if (checkbox.isSelected) {
					numChecked++;
				}
			}
			return numChecked;
		}
		
		/* ======================== */
		/* = clickHandler methods = */
		/* ======================== */
		
		/**
		 *	runs when checkbox is clicked
		 */
		private function checkBoxClicked(event:MouseEvent):void 
		{
			setButtonText("Check Answer");
			checkAnswersBtn.enabled = true;
		}
		
		/**
		 *	handler for checkAnswersBtn
		 */
		private function checkAnswersBtnClicked(event:MouseEvent):void 
		{
			switch (checkAnswersBtn.label){
				case "Check Answer" :
					// break out if there is a bad answer
					if (checkForBadResponse()){return;}				
					checkAnswer();
				break;
				case "Continue" :
					// send score to quiz
					sendScoreToQuiz();
				break;
			}
		}
		
		/**
		 *	sends score to quiz
		 */
		private function sendScoreToQuiz():void 
		{
			_parentQuiz.scoreAndContinue(_answeredCorrectly);
		}
		
		/**
		 *	get positive feedback from the array
		 */
		private function getPositiveFeedback():String
		{
			return positiveFeedbackArray[Math.floor(Math.random() * _positiveFeedbackArray.length)];
		}
		
		/* =============================================== */
		/* = methods for manipulating interface elements = */
		/* =============================================== */
		
		/**
		 *	hides all answers & marks
		 */
		private function hideAllAnswers():void 
		{
			for ( var i:int = 0; i < 5; i++ ) {
				this["check"+i].visible = false;
				this["answerMark"+i].visible = false;
				this["answerText"+i].visible = false;
			}
		}
		
		/**
		 *	disables all checkboxes
		 */
		private function disableCheckBoxes():void 
		{
			for ( var i:int = 0; i < _answers.length; i++ ) {
				this["check"+i].disable();
			}
		}
		
		/**
		 *	resets all checkboxes
		 */
		private function resetCheckBoxes():void{
			for ( var i:int = 0; i < _answers.length; i++ ) {
				var checkbox = this["check"+i];
				checkbox.enable();
				checkbox.enabled = true;
			}
		}
		
		/**
		 *	sets the label on the checkAnswerBtn
		 */
		private function setButtonText(buttonText:String):void{
			this.checkAnswersBtn.label = buttonText;
		}
		
		/**
		 *	sets formatting on the question and answer text fields
		 */
		private function setupTextFields():void 
		{
			questionText.autoSize=TextFieldAutoSize.LEFT;
			for (var i:int = 0; i<5; i++)
			{
				this["answerText"+i].autoSize = TextFieldAutoSize.LEFT;
			}
		}
		
		/* ================== */
		/* = Getter/Setters = */
		/* ================== */
		public function get question():String 
		{ 
			return _question; 
		}

		public function set question( value:String ):void 
		{
			if( value != _question ){
				_question = value;
			}
			questionText.text = _question;
		}
		
		public function get feedback():String 
		{ 
			return _feedback; 
		}

		public function set feedback( value:String ):void 
		{
			if( value != _feedback ){
				_feedback = value;
				this.feedbackText.text = _feedback;
			}
		}
		
		public function get negativeFeedback():String 
		{ 
			return _negativeFeedback; 
		}
		
		public function set negativeFeedback( arg:String ):void 
		{ 
            trace("setting negative feedback : ", arg);
			_negativeFeedback = arg; 
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
		
		public function get allowedTries():int 
		{ 
			return _allowedTries; 
		}

		public function set allowedTries( value:int ):void 
		{
			if( value != _allowedTries ){
				_allowedTries = value;
			}
		}
	}
}
