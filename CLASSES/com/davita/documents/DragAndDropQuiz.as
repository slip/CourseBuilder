/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import flash.filters.BlurFilter;

	import com.davita.buttons.LessonEnded;
	import com.greensock.TweenLite;
	import flash.utils.getQualifiedClassName;
	
	/**
	 *	A class to control Drag and Drop Quick Checks 
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0	
	 *
	 *	@author Ian Kennedy
	 *	@since  04.04.2008
	 */
	public class DragAndDropQuiz extends CourseSwf {
		
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
		private var _reviewText:String;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function DragAndDropQuiz(){
			this.stop();
			this.hasUnlimitedChances = false;

			getTotalQuestions();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// add event listeners to dragBoxes
			for (var i:int = 1; i < totalQuestions + 1; i++)
			{
				this["dragBox" + i].addEventListener(MouseEvent.MOUSE_DOWN, dragSelectedBox);
				this["dragBox" + i].addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
			}			
		}
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
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
			if(this.numChildren-1 > this.getChildIndex(event.target))
			{
				this.swapChildrenAt(this.numChildren-1, this.getChildIndex(event.target));
			}
			
			_dragX = event.target.x;
			_dragY = event.target.y;
			event.target.startDrag();
						
			// this avoids the confusion of mouseReleased
			// thinking the target is a z-higher dragbox
			if ((typeof event.target) == "object")
			{
				boxBeingDragged = event.target;
			}
		}
		
		private function mouseReleased(event:MouseEvent):void
		{
			event.target.stopDrag();
			trace(event.target.dropTarget);
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
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		private function checkAnswer(dragBox:MovieClip, dropBox:MovieClip):Boolean
		{
			this._tries++;
			
			// get the number of the drag & drop boxes
			var dropBoxNum:Number = dropBox.name.charAt(dropBox.name.length - 1);
			var dragBoxNum:Number = dragBox.name.charAt(dragBox.name.length - 1);
			
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
				goToReview();
			}	
			return true;
		}
		
		private function correctAnswerHandler(dragBox:MovieClip, dropBox:MovieClip):void
		{
			// correct answer
			// snap to the x and y of the target
			dragBox.x = dropBox.x + .5;
			dragBox.y = dropBox.y + .5;
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

		private function goToReview():void
		{
			// remove all dragBoxes
			for (var i:int = 1; i < totalQuestions + 1; i++)
			{
				removeChild(this["dragBox" + i]);
			}
			
			// set the review text for unlimited try quizzes
			if (this.hasUnlimitedChances)
			{
				this._reviewText = "You completed this exercise in " + this._tries + " tries.\n";
				if (this._tries == this.totalQuestions)
				{
					this._reviewText += "A perfect score, congratulations!!";
				}
				else if (this._tries - this.totalQuestions > 2) 
				{
					this._reviewText += "You completed this successfully but it took a few extra attempts. Take this time to review the content in this section before moving on.";
				}
				else 
				{
					this._reviewText += "You completed this successfully but it took an extra attempt or two. If you feel like you need to review, take the time to review the content in this section before moving on.";
				}
			}
			
			// review text for one-try only quizzes
			else 
			{
				this._reviewText = "You matched " + correctAnswers + " correctly and " + incorrectAnswers + " incorrectly.";					
			}
			
			// go to the review frame
			this.gotoAndStop("review");
		}
				
		private function disableDragBox(box:MovieClip):void
		{
			box.filters = [disabledBlur];
			box.removeEventListener(MouseEvent.MOUSE_DOWN, dragSelectedBox);
		}
	}	
}