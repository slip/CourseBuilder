/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.quiz
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import fl.controls.Button;
	import flash.filters.BlurFilter;
	import flash.utils.getQualifiedClassName;
	
	import com.davita.quiz.*;
	import com.greensock.TweenLite;
	import com.davita.buttons.LessonEnded;
	
	/**
	 *	base class for quiz items
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public class QuizItem_DD extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var totalQuestions:int = 0;
		private var incorrectAnswers:int = 0;
		private var correctAnswers:int = 0;

		private var _dragX:Number;
		private var _dragY:Number;
		
		private var disabledBlur:BlurFilter = new BlurFilter();
		
		private var boxBeingDragged:MovieClip;
		private var hasUnlimitedChances:Boolean = new Boolean();
		private var _tries:int = 0;
				
		public static const ANSWERED_CORRECTLY = 1;
		public static const ANSWERED_INCORRECTLY = 2;
		
		private var _parentQuiz:QuizCombined;
		private var _feedback:String;
		private var _positiveFeedbackArray:Array;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizItem_DD()
		{
			this.stop();

			getTotalQuestions();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 *	setup
		 */
		private function init(event:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			this.stop();
			checkAnswersBtn.enabled = false;
			setButtonText("Drag Answers");
			checkAnswersBtn.addEventListener(MouseEvent.CLICK, checkAnswersBtnClicked);
			_parentQuiz = (this.parent as QuizCombined);
			

			// add event listeners to dragBoxes
			for (var i:int = 1; i < totalQuestions + 1; i++)
			{
				this["dragBox" + i].addEventListener(MouseEvent.MOUSE_DOWN, dragSelectedBox);
				this["dragBox" + i].addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			}			
		}

		// loops over all items on the stage and 
		// totals up the number of dropBoxes
		private function getTotalQuestions():int
		{
			for (var i:int = 0; i < this.numChildren; i++)
			{
				var child = this.getChildAt(i);
				if (getQualifiedClassName(child) == "dropBox")
				{
					totalQuestions++;
				}
			}
			return totalQuestions;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function dragSelectedBox(event:MouseEvent):void
		{
			// move dragged object to the top
			if(this.numChildren-1 > this.getChildIndex(event.target as MovieClip))
			{
				this.swapChildrenAt(this.numChildren-1, this.getChildIndex(event.target as MovieClip));
			}
			
			_dragX = event.target.x;
			_dragY = event.target.y;
			event.target.startDrag();
						
			// this avoids the confusion of mouseReleased
			// thinking the target is a z-higher dragbox
			if ((typeof event.target) == "object")
			{
				boxBeingDragged = event.target as MovieClip;
			}
		}
		
		private function mouseReleased(event:MouseEvent):void
		{
			event.target.stopDrag();
			// trace(event.target.dropTarget);
			if((!event.target.dropTarget) || !(getQualifiedClassName(event.target.dropTarget.parent) == "dropBox"))
			{
				TweenLite.to(boxBeingDragged, .5, {x:_dragX, y:_dragY});
				return;
			}
			// check to see if the dragBox was released
			// over a drop box
			else if (getQualifiedClassName(event.target.dropTarget.parent) == "dropBox")
			{
				// if it was add a try and check the answer
				var dropBox:MovieClip = event.target.dropTarget.parent;
				checkAnswer(boxBeingDragged, dropBox);		
			}
		}
		
		/* ============================================ */
		/* = methods related to checking the response = */
		/* ============================================ */

		private function checkAnswer(dragBox:MovieClip, dropBox:MovieClip):Boolean
		{
			this._tries++;
			
			// get the number of the drag & drop boxes
			var dropBoxNum:Number = parseInt(dropBox.name.charAt(dropBox.name.length - 1));
			var dragBoxNum:Number = parseInt(dragBox.name.charAt(dragBox.name.length - 1));
			
			// compare the number of the drag and drop boxes			
			// if the number of the drop boxes matches they answered correctly
			if (dropBoxNum == dragBoxNum)
			{
				correctAnswerHandler(dragBox, dropBox);
			}
			// else if the number of the boxes don't match they answered incorrectly
			else 
			{
				incorrectAnswerHandler(dragBox, dropBox);
			}
			
			// see if correctAnswers + incorrectAnswers == totalAnswers
			if (correctAnswers + incorrectAnswers == totalQuestions)
			{
				prepareToContinue();
			}	
			return true;
		}
		
		private function correctAnswerHandler(dragBox:MovieClip, dropBox:MovieClip):void
		{
			// correct answer
			// snap to the x and y of the target
			dragBox.x = dropBox.x;
			dragBox.y = dropBox.y;
			// remove event listener
			dragBox.removeEventListener(MouseEvent.MOUSE_DOWN, dragSelectedBox);

			correctAnswers++;
		}
		
		private function incorrectAnswerHandler(dragBox:MovieClip, dropBox:MovieClip):void
		{
			/*  if there are unlimited chances
			*	then move the dragBox back to its origin
			*	otherwise move it back and disable it */
			if (this.hasUnlimitedChances)
			{
				TweenLite.to(dragBox, .5, {x:_dragX, y:_dragY});
			}
			else 
			{
				// disable the dragBox and
				// tween it back to the origin
				disableDragBox(dragBox);
				TweenLite.to(dragBox, .5, {x:_dragX, y:_dragY});			
				incorrectAnswers++;
			}
		}
		
		/**
		 *	disables checkboxes and sets button label to 'Continue'
		 */
		private function prepareToContinue():void 
		{
			checkAnswersBtn.enabled = true;
			
			if (correctAnswers == totalQuestions)
			{
				this.feedback = "Good Job";
				setButtonText("Continue");
			}
			else 
			{
				this.feedback = "Sorry, but that is incorrect.";
				setButtonText("Show correct answers");
			}
			
		}

		/**
		 *	sends score to quiz
		 */
		private function sendScoreToQuiz():void 
		{
			if (correctAnswers == totalQuestions)
			{
				_parentQuiz.scoreAndContinue(ANSWERED_CORRECTLY);
			}
			else 
			{
				_parentQuiz.scoreAndContinue(ANSWERED_INCORRECTLY);
			}
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
				case "Continue" :
					// send score to quiz
					sendScoreToQuiz();
				break;
				case "Show correct answers" :
					for (var i:int = 1; i < totalQuestions + 1; i++)
					{
						this["dragBox" + i].filters = null;
						TweenLite.to(this["dragBox" +i], 1, {x:this["dropBox" + i].x, y:this["dropBox" + i].y});
					}			
					
					setButtonText("Continue");
				break;
			}
		}

		private function disableDragBox(box:MovieClip):void
		{
			box.filters = [disabledBlur];
			box.removeEventListener(MouseEvent.MOUSE_DOWN, dragSelectedBox);
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
	}
}
