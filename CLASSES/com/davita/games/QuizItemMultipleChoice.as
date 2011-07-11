/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.games
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import fl.controls.*;
	import com.davita.elements.IKCheckBox;
	
	/**
	 *  QuizItemMultipleChoice is a multiple choice quiz item. surprise?
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  20.11.2007
	 */
	public class QuizItemMultipleChoice extends MovieClip
	{
		var answers:Array = new Array();
		var correctAnswer:int;
		var tries:int;
		var correctFeedback:String;
		var incorrectFeedback:String;
		
		public var reviewPage:String;
		public var readyToContinue:Boolean = new Boolean();
		
		private var quizReview:QuizGameReview;
		private var reviewCloseBtn:ReviewCloseBtn = new ReviewCloseBtn();
		
		private var correctSound:CorrectSound = new CorrectSound();
		private var incorrectSound:IncorrectSound = new IncorrectSound();
		
		
		/**
		 *	@constructor
		 */
		public function QuizItemMultipleChoice()
		{
			// set listener for answer clicked
			for (var i:int = 0; i<4; i++)
			{
				this["check"+i].addEventListener(MouseEvent.CLICK, answerClicked);
				this["check"+i].visible = false;
				this["answerMark"+i].visible = false;
				this["answerText"+i].embedFonts = true;
			}
			
			checkAnswers_btn.addEventListener(MouseEvent.CLICK, checkAnswers);
			
			// set feedback
			setFeedback("");
			// set labels for checkboxes and buttons		
			setButtonText("Choose Answer");
			tries = 0;
			
			this.readyToContinue = false;
			
			this.questionTxt.embedFonts = true;
			this.feedbackTxt.embedFonts = true;
		}
		
		private function answerClicked(event:MouseEvent):void
		{
			setButtonText("Check Answer");
		}
				
		public function setQuestion(question:String):void{
			this.questionTxt.text = question;
		}

		public function setAnswer(answer:String):void{
			answers.push(answer);
		}		

		public function setCorrectAnswer(answer:int):void{
			correctAnswer = answer;
		}

		public function getCorrectAnswer():String{
			return answers[correctAnswer-1];
		}

		public function setFeedback(feedbackText:String):void{
			this.feedbackTxt.htmlText = feedbackText;
		}

		public function setCorrectFeedback(feedbackText:String):void{
			correctFeedback = feedbackText;
		}

		public function setIncorrectFeedback(feedbackText:String):void{
			incorrectFeedback = feedbackText;
		}

		public function setButtonText(buttonText:String):void{
			this.checkAnswers_btn.label = buttonText
		}

		public function getButtonText():String{
			return this.checkAnswers_btn.label;
		}

		public function setCheckBoxes():void{				
			for ( var i:int = 0; i < answers.length; i++ ) 
			{
				var checkbox = this["answerText"+i];
				checkbox.text = answers[i];
				this["check"+i].visible = true;
				this["answerMark"+i].visible = true;
			}
		}

		public function resetCheckBoxes():void{
			setButtonText("Choose Answer");
			for ( var i:int = 0; i < answers.length; i++ ) {
				var checkbox = this["check"+i];
				checkbox.enable();
				checkbox.enabled = true;
			}
		}

		public function disableCheckBoxes():void{
			for ( var i:int = 0; i < answers.length; i++ ) {
				var checkbox = this["check"+i];
				checkbox.disable();
			}
		}

		public function disableComponents():void{
			if (this.readyToContinue)
			{
				// this is where things should move forward if correct
				nextQuestion();
//				checkAnswers_btn.removeEventListener(MouseEvent.CLICK, checkAnswers);
//				checkAnswers_btn.addEventListener(MouseEvent.CLICK, nextQuestion);
//				setButtonText("Continue");
			}			
			else 
			{
				checkAnswers_btn.removeEventListener(MouseEvent.CLICK, checkAnswers);
				checkAnswers_btn.addEventListener(MouseEvent.CLICK, goToReview);
				setButtonText("Review");
			}
			disableCheckBoxes();
		}

		public function goToReview(event:MouseEvent):void
		{
			quizReview = new QuizGameReview(this.reviewPage);
			reviewCloseBtn.addEventListener(MouseEvent.CLICK, closeReview);
			
			addChild(quizReview);
			reviewCloseBtn.x = -23;
			reviewCloseBtn.y = 457;
			addChild(reviewCloseBtn);
		}
		
		private function closeReview(e:Event):void
		{
			this.removeChild(quizReview);
			this.removeChild(reviewCloseBtn);
			setFeedback("Now that you've reviewed, try again.");
			tries = 0;
			resetCheckBoxes();
			checkAnswers_btn.removeEventListener(MouseEvent.CLICK, goToReview);
			checkAnswers_btn.addEventListener(MouseEvent.CLICK, checkAnswers);
		}
		
		public function nextQuestion():void
		{
			var label:String = this.parent.currentLabel;
			var dot:MovieClip = this.parent.parent["dot"+label];

			this.parent.parent.mcCorrect.play();
			
			if (this.parent.parent.questionsAnswered == this.parent.parent.numberOfQuestions)
			{
				this.parent.gotoAndStop(1);
				dot.gotoAndStop(2);
				this.parent.parent.play();
			}
			else
			{
				this.parent.gotoAndStop(1);
				dot.gotoAndStop(2);
			}
		}
		
		public function checkForBadResponse():Boolean{
			// check for no answers or more than one answer
			var numChecked:int = 0;
			for ( var i:int = 0; i < answers.length; i++ ) {
				var checkbox = this["check"+i];
				if (checkbox.isSelected) {
					numChecked++;
				}
			}
			
			if (numChecked == 0)
			{
				setFeedback("Please enter an answer.");
				return true;
			}
			
			if (numChecked > 1)
			{
				setFeedback("Check only one answer.");
				resetCheckBoxes();
				return true;
			}
			
			return false;
		}
		
		public function checkAnswers(event:MouseEvent):void{
			if (checkForBadResponse() == true)
			{
				return;
			}
						
			// get the selected checkboxes
			var selected:int;
			for ( var i:int = 0; i < answers.length; i++ ) {
				var checkbox = this["check"+i];
				if (checkbox.isSelected) {
					selected = i+1;
				}
			}

			// first try
			if (tries == 0) {
				// see if they got it right
				if (selected == correctAnswer) {
					this.readyToContinue = true;
					setFeedback(correctFeedback);
					disableComponents();
					correctSound.play();
				}
				// else they got it wrong
				else {
					disableCheckBoxes();
					tries++;
					setFeedback(incorrectFeedback + " Try again.");
					setButtonText("Reset");
					incorrectSound.play();
				}
			}

			// second try
			else {
				// see if the label is 'reset'
				if (getButtonText() == "Reset") {
					resetCheckBoxes();
					setButtonText("Check Answer");
					setFeedback("");
				}
				// see if they got it right
				else if (selected == correctAnswer) {
					this.readyToContinue = true;
					disableComponents();
					setFeedback(correctFeedback);
					correctSound.play();
				}
				// else they got it wrong
				else {
					tries++;
					disableComponents();
					setFeedback(incorrectFeedback);
					incorrectSound.play();
				}	
			}
		}
	}
}