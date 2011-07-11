/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.test
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import fl.controls.*;
	import com.davita.events.ReviewEvent;
	import com.davita.test.TestItem;
	import flash.utils.getQualifiedClassName;
	import flash.external.*;
	import com.greensock.TweenLite;
	
	/**
	 *	base class for post test
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class CourseTest extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var xmlLoader:URLLoader = new URLLoader();			
		private var testXml:XML;
		
		private var testItems:Array = new Array();
		
		private var currentTestItem:TestItem;
		private var currentQuestionNumber:Number;
		private var numOfQuestionsAnsweredCorrectly:Number;
		private var numOfQuestionsAnsweredIncorrectly:Number;
		
		private var testTitle:String;
		private var passingScore:Number;
		private var positiveFeedbackArray:Array = new Array("Great Job!", "That's right!", "Nicely answered!", "You got it!","You're a whiz!");
		
		public var myParent:MovieClip;
				
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function CourseTest()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			setUpFonts();
			if (this.parent.parent != null)
			{
				myParent = parent.parent as MovieClip;
			}
			
			// initial values
			currentQuestionNumber = 1;
			numOfQuestionsAnsweredCorrectly = 0;
			numOfQuestionsAnsweredIncorrectly = 0;
			
			xmlLoader.load(new URLRequest("test.xml"));
						
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorTest);
			
			// event listeners
			for (var i:int = 0; i<4; i++)
			{
				this["answerButton"+i].addEventListener(MouseEvent.CLICK, answerClicked);
			}

			nextQuestionButton.addEventListener(MouseEvent.CLICK, nextQuestion);

			nextQuestionButton.visible = false;			
			hideAllAnswers();			
			
		}
		
		private function setUpFonts():void
		{
			title_txt.embedFonts = true;
			questionText.embedFonts = true;
			questionNumText.embedFonts = true;
			feedbackText.embedFonts = true;
			for (var i:int = 0; i<4; i++)
			{
				this["answerText"+i].embedFonts = true;
			}
		}
		
		private function errorTest(event:IOErrorEvent):void 
		{
			xmlLoader.load(new URLRequest("../test.xml"));
		}
		
		private function nextQuestion(event:MouseEvent):void
		{
			TweenLite.to(nextQuestionButton, 1, {alpha:0});
			hideAllAnswers();
			if (currentQuestionNumber == testItems.length+1)
			{					
				gotoAndStop("summary");
			}
			else
			{
				askQuestion();				
			}
		}
		
		private function getPositiveFeedback():String
		{
			return positiveFeedbackArray[Math.floor(Math.random()*positiveFeedbackArray.length)];
		}
		
		private function disableAnswerButtons():void
		{
			for (var i:int = 0; i<4; i++)
			{
				this["answerButton"+i].disable();
				this["answerButton"+i].removeEventListener(MouseEvent.CLICK, answerClicked);
			}			
		}

		private function enableAnswerButtons():void
		{
			for (var i:int = 0; i<4; i++)
			{
				this["answerButton"+i].enable();
				this["answerButton"+i].addEventListener(MouseEvent.CLICK, answerClicked);
			}			
		}
		
		private function answerClicked(event:MouseEvent):void
		{
			currentQuestionNumber++;
			// disable answer buttons and display next question button
			disableAnswerButtons();
			nextQuestionButton.visible = true;
			TweenLite.to(nextQuestionButton, 1, {alpha:1});
			
			// determine whether the answer was correct or incorrect.
			// let's do this by stripping the number off the end
			// of the button name and checking it using the currentTestItem.checkAnswerNumber. 
			var targetName:String = event.target.name;
			var answerNum:Number = targetName.charAt(12);
			var isCorrect:String = currentTestItem.checkAnswerNumber(answerNum);
			
			// display correct or incorrect feedback
			if (isCorrect == "correct")
			{
				numOfQuestionsAnsweredCorrectly++;
				feedbackText.text = getPositiveFeedback();
			}
			else 
			{
				numOfQuestionsAnsweredIncorrectly++;
				feedbackText.text = currentTestItem.getFeedback();
			}			
		}
		
		private function askQuestion():void 
		{
			currentTestItem = testItems[currentQuestionNumber-1];
			var hasAnswered:Boolean = false;
			
			var question:String = currentTestItem.getQuestion();
			var feedback:String = currentTestItem.getFeedback();
			
			// enable answer buttons, hide nextQuestionButton and clear feedback
			enableAnswerButtons();
			feedbackText.text = "";
			
			// put question into question textfield
			questionText.text = question;
			
			for (var i:int = 0; i<currentTestItem.getNumOfAnswers(); i++)
			{
				var answer:String = currentTestItem.getAnswer(i);
				setAnswerText(this["answerText" + i], answer);
			}
			setQuestionNumText();
			showAnswers();
		}

		private function setQuestionNumText():void
		{
			questionNumText.text =  currentQuestionNumber + "/" + (testItems.length);
		}
		
		private function setAnswerText(textField:TextField, answerText:String):void 
		{
			textField.text = answerText;
		}
		
		private function hideAllAnswers():void
		{
			for (var i:int = 0; i<4; i++)
			{
				this["answerButton"+i].visible = false;
				this["answerMark"+i].visible = false;
				this["answerText"+i].visible = false;
			}
		}
		
		private function showAnswers():void
		{
			for (var i:int = 0; i<currentTestItem.getNumOfAnswers(); i++)
			{
				this["answerButton"+i].visible = true;
				this["answerMark"+i].visible = true;
				this["answerText"+i].visible = true;				
			}
		}
		
		/**
		 *	triggered once the xml has loaded
		 *	loads xml and populates testItem array
		 */
		private function xmlLoaded(event:Event):void
		{
			// convenience variable
			testXml = XML(event.target.data);

			// set test title
			setTestTitle(testXml.@title);
			passingScore = parseInt(testXml.@passingScore);
			
			setTitleText();
			
			// add TestItems to testItems array
			for (var i:int = 0; i<testXml.*.length(); i++)
			{
				var testItem = testXml.*[i];
				var question:String = testItem.@question;
				var feedback:String = testItem.@feedback;
				
				// add a quizItem
				testItems[i] = new TestItem(question.toString(), feedback);
				var answers:XMLList = testItem.*;
				
				for (var j:int = 0; j<answers.length(); j++)
				{
					var isCorrectAnswer = false;
					var answer = answers[j];
					if (answer.@correct == "y")
					{
						isCorrectAnswer = true;
					}
					testItems[i].addAnswer(answer, isCorrectAnswer);
				}
			}
			askQuestion();
		}

		private function getTestTitle():String 
		{ 
			return testTitle; 
		}
		
		private function setTestTitle(value:String):void 
		{
			if(value != testTitle)
			{
				testTitle = value;
			}
		}
		
		private function setTitleText():void
		{
			var t:String = getTestTitle();
			title_txt.text = t;
		}
	}	
}
