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
	public class TextEntry extends TextInput {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var labelFormat = new TextFormat("Arial", "12");
		public var _myParent:MovieClip;
		public var expectedString:String;
		private var validateImmediately:Boolean = new Boolean();
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function TextEntry(){
			super();
			this.validateImmediately = false;
			this.setFocus();
			this.drawFocus(false);
			addEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = (this.parent as MovieClip);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(ComponentEvent.ENTER, validateUserInput);
			addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			this._myParent.stop();
		}
		
		public function setValidateImmediately(value:Boolean):void
		{
			if (validateImmediately != value)
			{
				validateImmediately = value;
			}
		}
		
		public function getValidateImmediately():Boolean
		{
			return validateImmediately;
		}
		
		public function isWaitingFor(value:String):void
		{
			if (expectedString != value)
			{
				expectedString = value;
			}
		}
		
		private function playIncorrectIndicator():void
		{
			this.drawFocus(true);
		}
		
		override protected function drawTextFormat():void
		{
			textField.setTextFormat(labelFormat);
			textField.defaultTextFormat = labelFormat;
		}
		
		override protected function drawBackground():void
		{
			// don't draw background
		}
		
		override protected function handleKeyDown(event:KeyboardEvent):void 
		{
			if (event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.TAB) {
				dispatchEvent(new ComponentEvent(ComponentEvent.ENTER, true));
			}
		}
		
		private function handleKeyUp(event:KeyboardEvent):void
		{
			if (validateImmediately)
			{
				// check to see if the user has typed enough characters
				if (this.text.length == expectedString.length)
				{
					// check for a match
					if (inputMatchesExpected())
					{
						this.removeEventListener(ComponentEvent.ENTER, validateUserInput);
						this.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
						_myParent.interactions.push(_myParent.currentFrame);
						_myParent.play();
					}
					else
					{
						this.setSelection(0, this.text.length);
						playIncorrectIndicator();
					}
				}
			}
		}
		
		private function inputMatchesExpected():Boolean
		{
			var userInput:String = this.text;
			if (userInput.toLowerCase() == expectedString.toLowerCase())
			{
				return true;
			} else {
				return false;
			}
		}
		
		public function validateUserInput(e:ComponentEvent)
		{
			var userInput:String = this.text;
			if (inputMatchesExpected())
			{
				this.removeEventListener(ComponentEvent.ENTER, validateUserInput);
				this.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
				_myParent.interactions.push(_myParent.currentFrame);
				this._myParent.play();
			} 
			else 
			{
				this.setSelection(0, userInput.length);
				playIncorrectIndicator();
			}
		}
	}
	
}
