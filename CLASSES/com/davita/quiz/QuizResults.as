/* AS3
	Copyright 2009 normal design.
*/
package com.davita.quiz {
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	/**
	 *	Class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  19.02.2009
	 */
	public class QuizResults extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		public var correctQuestions:Array = new Array();
		public var incorrectQuestions:Array = new Array();
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizResults()
		{
			this.stop();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void 
		{
			feedbackTextField.autoSize = TextFieldAutoSize.LEFT;
			numCorrectTextField.text = correctQuestions.length.toString();
			numIncorrectTextField.text = incorrectQuestions.length.toString();
			giveFeedback();
		}
				
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		private var _positiveFeedback:Array;
		private var _negativeFeedback:Array;
		private var _mixedFeedback:Array;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		public function get positiveFeedback():Array 
		{ 
			return _positiveFeedback; 
		}

		public function set positiveFeedback( value:Array ):void 
		{
			if( value != _positiveFeedback ){
				_positiveFeedback = value;
			}
		}

		public function get negativeFeedback():Array 
		{ 
			return _negativeFeedback; 
		}

		public function set negativeFeedback( value:Array ):void 
		{
			if( value != _negativeFeedback ){
				_negativeFeedback = value;
			}
		}

		public function get mixedFeedback():Array 
		{ 
			return _mixedFeedback; 
		}

		public function set mixedFeedback( value:Array ):void 
		{
			if( value != _mixedFeedback ){
				_mixedFeedback = value;
			}
		}		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		private function giveFeedback():void 
		{
			switch (getMode()){
				case "allCorrect" :
					feedbackTextField.text = getPositiveFeedback();
				break;
				case "allWrong" :
					feedbackTextField.text = getNegativeFeedback();
				break;
				case "mixed" :
					feedbackTextField.text = getMixedFeedback();
				break;
			}
		}
		
		/**
		 *	returns allCorrect, allWrong, or mixed
		 */
		private function getMode():String 
		{
			var totalQuestions:Number = correctQuestions.length + incorrectQuestions.length;
			if (totalQuestions == correctQuestions.length)
			{
				return "allCorrect";
			} else if (totalQuestions == incorrectQuestions.length) 
			{
				return "allWrong";
			} else 
			{
				return "mixed"
			}
		}

		/**
		 *	get positive feedback from the array
		 */
		private function getPositiveFeedback():String
		{
			return positiveFeedback[Math.floor(Math.random() * _positiveFeedback.length)];
		}
		
		/**
		 *	get negative feedback from the array
		 */
		private function getNegativeFeedback():String
		{
			return negativeFeedback[Math.floor(Math.random() * _negativeFeedback.length)];
		}
		
		/**
		 *	get positive feedback from the array
		 */
		private function getMixedFeedback():String
		{
			return mixedFeedback[Math.floor(Math.random() * _mixedFeedback.length)];
		}
		
	}
}
