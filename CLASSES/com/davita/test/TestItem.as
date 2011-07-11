/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.test
{
	/**
	 *	base class for post test items
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class TestItem {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		public var question:String;
		public var feedback:String;
		public var answers:Array = new Array();
		public var numOfAnswers:Number;
		public var correctAnswer:Number;
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function TestItem(question:String, feedback:String)
		{
			this.question = question;
			this.feedback = feedback;
			numOfAnswers = 0;
			correctAnswer = 0;
		}
				
		public function addAnswer(answer:String, isCorrectAnswer:Boolean):void 
		{
			this.answers[numOfAnswers] = answer;
			if (isCorrectAnswer)
			{
				correctAnswer = numOfAnswers;
			}
			this.numOfAnswers++;
		}
		
		public function getQuestion():String
		{
			return question;
		}

		public function getFeedback():String
		{
			return feedback;
		}
		
		public function getAnswer(answerNumberToGet:Number):String
		{
			return answers[answerNumberToGet];
		}
		
		public function getNumOfAnswers():Number
		{
			return answers.length;
		}
		
		public function getCorrectAnswerNumber():Number
		{
			return this.correctAnswer;
		}
		
		
		public function checkAnswerNumber(answerNumber:Number):String
		{
			if (answerNumber == getCorrectAnswerNumber())
			{
				return("correct");
			}
			else
			{
				return("incorrect");
			}
		}
		
	}
	
}
