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
	 *  QuizItemFillTheBlank is a fill-in-the-blank quiz item. surprise?
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  20.11.2007
	 */
	public class QuizItemFillTheBlank extends MovieClip
	{
		private var answer1:String;
		private var answer2:String;

		private var correctFeedback:String;
		private var incorrectFeedback:String;
		
		public var reviewPage:String;
		public var readyToContinue:Boolean = new Boolean();
		
		private var quizReview:QuizGameReview;
		private var reviewCloseBtn:ReviewCloseBtn = new ReviewCloseBtn();
		
		private var correctSound:CorrectSound = new CorrectSound();
		private var incorrectSound:IncorrectSound = new IncorrectSound();
		
		/**
		 *	@constructor
		 */
		public function QuizItemFillTheBlank()
		{	
			checkAnswerBtn.addEventListener(MouseEvent.CLICK, checkAnswers);
			
			// set feedback
			setFeedback("");
			// set labels for checkboxes and buttons		
			setButtonText("Fill in the Blanks");
			tries = 0;
			
			this.readyToContinue = false;
			
			this.feedbackTxt.embedFonts = true;
		}
		
		private function answerClicked(event:MouseEvent):void
		{
			setButtonText("Check Answer");
		}
				
		public function setQuestion(question:String):void{
			this.questionTxt.text = question;
		}

		public function setAnswer1(answer:String):void{
			this.answer1 = answer;
		}		

		public function setAnswer2(answer:String):void{
			this.answer2 = answer;
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
			this.checkAnswerBtn.label = buttonText
		}

		public function getButtonText():String{
			return this.checkAnswerBtn.label;
		}

		public function resetBlanks():void{
			setButtonText("Fill in the blanks.");
			blank1.text = "";
			blank2.text = "";
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
			resetBlanks();
			checkAnswerBtn.removeEventListener(MouseEvent.CLICK, goToReview);
			checkAnswerBtn.addEventListener(MouseEvent.CLICK, checkAnswers);
		}
		
		public function nextQuestion():void
		{
			var label:String = this.parent.currentLabel;
			var dot:MovieClip = this.parent.parent["dot"+label];
			
			dot.gotoAndStop(2);
			
			this.parent.parent.mcCorrect.play();
			
			if (this.parent.parent.questionsAnswered == this.parent.parent.numberOfQuestions)
			{
				this.parent.gotoAndStop(1);
				this.parent.parent.play();
			}
			else
			{
				this.parent.gotoAndStop(1);
			}
		}
		
		public function checkForBadResponse():Boolean{
			// check to see if both blanks are filled in
			
			if (blank1.text == "" || blank2.text == "")
			{
				setFeedback("Please fill in both blanks.");
				return true;
			}
			
			return false;
		}
		
		public function checkAnswers(event:MouseEvent):void{
			if (checkForBadResponse() == true)
			{
				return;
			}
						
			// they got it right
			if (answer1.toLowerCase() == stripWhitespace(blank1.text.toLowerCase()) && answer2.toLowerCase() == stripWhitespace(blank2.text.toLowerCase()))
			{
				setFeedback(correctFeedback);
				checkAnswerBtn.removeEventListener(MouseEvent.CLICK, checkAnswers);
				nextQuestion();
				setButtonText("Continue");
				correctSound.play();
			}
			// they got it wrong
			else 
			{
				setFeedback(incorrectFeedback + "Take a minute to review and try again.");
				checkAnswerBtn.removeEventListener(MouseEvent.CLICK, checkAnswers);
				checkAnswerBtn.addEventListener(MouseEvent.CLICK, goToReview);
				setButtonText("Review");
				incorrectSound.play();
			}
		}
		
		public function stripWhitespace(string:String, options:String = null):String
		        {
		            // default is to strip all
		            var result:String = string;
		            var resultArray:Array;
		            // convert tabs to spaces
		            if(options == null || options.indexOf("t",0) > -1)
		                result = result.split("\t").join(" ");
		            // convert returns to spaces
		            if(options == null || options.indexOf("r",0) > -1)
		                result = result.split("\r").join(" ");
		            // convert newlines to spaces
		            if(options == null || options.indexOf("n",0) > -1)
		                result = result.split("\n").join(" ");
		            // compress spaces
		            if(options == null || options.indexOf("s",0) > -1) {
		                resultArray = result.split(" ");
		                for(var idx:uint = 0; idx < resultArray.length; idx++)
		                {
		                    if(resultArray[idx] == "")
		                    {
		                        resultArray.splice(idx,1);
		                        idx--;
		                    }
		                }
		                result = resultArray.join(" ");
		            }
		            return result;
		        }
		
		
	}
}