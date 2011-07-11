/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.quiz
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import fl.controls.*;
	import com.davita.documents.CourseSwf;
	import com.davita.quiz.*;
	import com.greensock.TweenLite;
	
	/**
	 *	base class for post quiz
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class QuizCombined extends CourseSwf {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		public static const ANSWERED_CORRECTLY = 1;
		public static const ANSWERED_INCORRECTLY = 2;
		
        private var _quizType:String = "";
		private var _quizQuestions:Array = new Array();
		
		private var _currentQuizQuestion;
		private var _currentQuestionNumber:Number;
		private var quizReview:QuizResults = new QuizResultsStandard();
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizCombined()
		{	
			this.stop();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			_currentQuestionNumber = 0;
		}

		public function scoreAndContinue(answeredCorrectly:Number):void 
		{
			// adds answer to correct or incorrect array
			if (answeredCorrectly == ANSWERED_CORRECTLY)
			{
				this.quizReview.correctQuestions.push(_currentQuizQuestion);
				
			} else if (answeredCorrectly == ANSWERED_INCORRECTLY) 
			{
				this.quizReview.incorrectQuestions.push(_currentQuizQuestion);
			}
			this.removeChild(_currentQuizQuestion);
			_currentQuizQuestion = null;
			_currentQuestionNumber++;
			nextQuestion();
		}
		
		private function beginQuiz():void 
		{
			_currentQuizQuestion = new _quizQuestions[0]();
			addQuestionToStage(_currentQuizQuestion);
		}
		
		private function nextQuestion():void
		{
			if (_currentQuestionNumber == quizQuestions.length)
			{	
				addEndBtnToStage();
				addResultsToStage();
			}
			else
			{
				_currentQuizQuestion = new _quizQuestions[_currentQuestionNumber]();
				addQuestionToStage(_currentQuizQuestion);
			}
		}
		
		private function addResultsToStage():void
		{
			this.quizReview.x = 70;
			this.quizReview.y = 100;
			this.quizReview.alpha = 0;
			this.addChild(this.quizReview);
			TweenLite.to(this.quizReview, 2, {alpha:1});
		}
		
		/**
		 *	adds question at correct position
		 */
		private function addQuestionToStage(question):void 
		{
			// TODO: question.x and .y should be dynamic
			question.x = 70;
			question.y = 100;
			question.alpha = 0;
			this.addChild(question);
			TweenLite.to(question, 2, {alpha:1});
		}
		
		/**
		 *	adds lessonEndedBtn at correct position
		 */
		private function addEndBtnToStage():void 
		{
            var endBtn:MovieClip;
            if (this._quizType == "Falcon") {
                endBtn = new LessonEndedLtBtn();
            } else {
                endBtn = new LessonEndedBtn();
            }
            
			endBtn.x = 70;
			endBtn.y = 535;
			
			this.addChild(endBtn);
		}

        public function setQuizType(quiztype:String):void
        {
            this._quizType = quiztype;
        }
		
		public function get quizQuestions():Array 
		{ 
			return _quizQuestions; 
		}
		
		public function set quizQuestions(questions:Array):void 
		{
			if( questions != _quizQuestions ){
				_quizQuestions = questions;
			}
		}
	}	
}
