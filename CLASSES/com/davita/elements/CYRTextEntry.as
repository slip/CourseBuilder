/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements {
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.*;
	import fl.events.ComponentEvent;
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	
	/**
	 *	A subclass of TextInput which validates user-entered text
	 *	by comparing it to the expected string.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  12.03.2008
	 */
	public class CYRTextEntry extends TextInput {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var _myParent:MovieClip;
		private var _originalString:String;
		private var _expectedString:String;
		private var numberOfRequiredLetters:Number = 3;

		private var defaultFormat:TextFormat = new TextFormat("Verdana", "12", 0x000000);
		private var incorrectFormat:TextFormat = new TextFormat();
		private var correctFormat:TextFormat = new TextFormat();		
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function CYRTextEntry(){
			super();
			this.setStyle("textFormat", defaultFormat)
			this.focusRect = null;
			this.drawFocus(false);
			addEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = (this.parent as MovieClip);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			
			// set up formats
	        incorrectFormat.color = 0xC32B4A;
	        incorrectFormat.size = 12;
			
	        correctFormat.color = 0x286017;
	        correctFormat.size = 12;
			
		}
				
		public function isWaitingFor(string:String):void
		{
			numberOfRequiredLetters = _myParent.getNumberOfRequiredLetters();
			if (numberOfRequiredLetters == -1)
			{
				_expectedString = string;
			}
			else
			{
				_expectedString = string.slice(0, numberOfRequiredLetters);
				trace("_expectedString: " + _expectedString);
			}
			_originalString = string;
		}
		
		private function playIncorrectIndicator():void
		{
			this.setStyle("textFormat", incorrectFormat);
			_myParent.hint();
		}
		
		public function playCorrectIndicator():void
		{
			this.setStyle("textFormat", correctFormat);
			this.text = _originalString;
			this.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			this.editable = false;
			textField.selectable = false;
			this.focusEnabled = false;
			this.drawFocus(false);
			_myParent.correctAnswer();
		}
				
		private function handleKeyUp(event:KeyboardEvent):void
		{
			// check to see if the user has typed enough characters
			
			var numberOfRequiredLetters:int = _myParent.getNumberOfRequiredLetters();
			
			if (numberOfRequiredLetters == -1)
			{
				numberOfRequiredLetters = this._expectedString.length;
			}
			
			if (this.text.length == numberOfRequiredLetters)
			{
				// check for a match
				if (inputMatchesExpected())
				{
					playCorrectIndicator();
				}
				else
				{
					this.setSelection(0, this.text.length);
					playIncorrectIndicator();
				}
			}
		}
		
		private function inputMatchesExpected():Boolean
		{
			var userInput:String = this.text;
			
			if (userInput.toLowerCase() == _expectedString.toLowerCase())
			{
				return true;
			} 
			else 
			{
				return false;
			}
		}
	}
}
