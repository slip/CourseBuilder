/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import fl.controls.*;
	import com.davita.events.ReviewEvent;
	import com.davita.buttons.LessonEnded;
	import com.davita.elements.IKCheckBox;
	
	/**
	 *  QuickCheckMC is a multiple choice quiz
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  20.11.2007
	 */
	public class QuickCheckMC extends CourseSwf
	{
		var answers:Array = new Array();
		var correctAnswer:int;
		var tries:int;
		var correctFeedback:String;
		var incorrectFeedback:String;
		
		var keywords:Array = new Array();
		var _reviewInfo:Array = new Array();
		
		/**
		 *	@constructor
		 */
		public function QuickCheckMC()
		{
			// set listener for answer clicked
			for (var i:int = 0; i<4; i++)
			{
				this["check"+i].addEventListener(MouseEvent.CLICK, answerClicked);
			}
			
			checkAnswers_btn.addEventListener(MouseEvent.CLICK, checkAnswers);
			
			// set feedback
			setFeedback("");
			// set labels for checkboxes and buttons		
			setButtonText("Choose Answer");
			tries = 0;
			
			lessonEnded.visible = false;
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
			for ( var i:int = 0; i < answers.length; i++ ) {
				var checkbox = this["answerText"+i];
				checkbox.text = answers[i];
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
			this.checkAnswers_btn.enabled = false;
			disableCheckBoxes();
		}

		public function checkBadResponse():Boolean{
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
				resetCheckBoxes();
				setFeedback("Check only one answer.");
				return true;
			}
			
			return false;
		}
		
		/**
		 *	sets the reviewInfo Array
		 *	_reviewInfo = [1, "keyword1", "keyword2", "keyword3"]
		 */
        private function setReviewInfo(info:Array):void
        {
            _reviewInfo = info;
        }

		public function checkAnswers(event:MouseEvent):void{
			if (checkBadResponse() == true)
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
					setFeedback(correctFeedback);
					disableComponents();
					keywords.unshift(tries);
					setReviewInfo(keywords);
					dispatchEvent(new ReviewEvent(ReviewEvent.REVIEW_CHANGED, _reviewInfo));
					lessonEnded.visible = true;
				}
				// else they got it wrong
				else {
					tries++;
					disableCheckBoxes();
					setFeedback(incorrectFeedback + " Try again.");
					setButtonText("Reset");
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
					keywords.unshift(tries);
					setReviewInfo(keywords);
					dispatchEvent(new ReviewEvent(ReviewEvent.REVIEW_CHANGED, _reviewInfo));
					disableComponents();
					setFeedback(correctFeedback);
					lessonEnded.visible = true;
				}
				// else they got it wrong
				else {
					tries++;
					keywords.unshift(tries);
					setReviewInfo(keywords);
					dispatchEvent(new ReviewEvent(ReviewEvent.REVIEW_CHANGED, _reviewInfo));
					disableComponents();
					setFeedback(incorrectFeedback + " The correct answer is: <b>" + getCorrectAnswer() + "</b>.");
					lessonEnded.visible = true;
				}	
			}
		}
	}
}