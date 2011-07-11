/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.popups
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.filters.*;
	import com.davita.buttons.DynamicButton;
	import com.greensock.TweenLite;

	public class HelpReminder extends MovieClip
	{
		private var _backGround:Sprite = new Sprite();
		private var _textBackGround:Sprite = new Sprite();
		
		private var textFormat:TextFormat = new TextFormat();	
		private var helpTxt:TextField = new TextField();
		
		public var closeBtn:DynamicButton = new DynamicButton(100, 30, 5, "Close");
		
		private var _message:String = "We couldn't help but notice you haven't clicked anything yet and we’re concerned you need help navigating through the course. If that’s true, close this alert and click the round blue question mark in the lower left area of the course window for assistance.";

		public function HelpReminder()
		{
			this.y = 60;
			TweenLite.to(this, 1, {alpha:1, onComplete:drawBackground});
		}
		
		private function drawBackground():void
		{
			_backGround.graphics.beginFill(0x000000);
			_backGround.graphics.drawRect(0,.5,1000,599.5);
			_backGround.alpha = 0;
			TweenLite.to(_backGround, 4, {alpha:.85, onComplete:drawTextBackground});
			addChild(_backGround);
		}
		
		private function drawTextBackground():void
		{
			_textBackGround.graphics.beginFill(0xFFFFFF);
			_textBackGround.graphics.lineStyle(3, 0xE5843E);
			_textBackGround.graphics.drawRoundRect(0,0,300,160,20,20);
			_textBackGround.x = 350;
			_textBackGround.y = 200;
			_textBackGround.alpha = .0;
			TweenLite.to(_textBackGround, 1.5, {alpha:1, onComplete:displayMessage});
			addChild(_textBackGround);
		}
		
		private function displayMessage():void
		{
			textFormat.font = "Gotham Medium";
			textFormat.size = 12;
			textFormat.leading = 5;
			textFormat.color = 0x000000;

			helpTxt.defaultTextFormat = textFormat;
			helpTxt.text = _message;
			helpTxt.x = 10;
			helpTxt.y = 10;
			helpTxt.width = 285;
			helpTxt.multiline = true;
			helpTxt.wordWrap = true;
			helpTxt.autoSize = TextFieldAutoSize.LEFT;
			helpTxt.embedFonts = true;
			helpTxt.antiAliasType = AntiAliasType.ADVANCED;
			helpTxt.alpha = .0;
			
			TweenLite.to(helpTxt, 1, {alpha:1, onComplete:drawButton});
			_textBackGround.addChild(helpTxt);
		}
		
		private function drawButton():void
		{
			closeBtn.x = 10;
			closeBtn.y = _textBackGround.height - 45;
			closeBtn.alpha = .0;
			TweenLite.to(closeBtn, 1, {alpha:1});
			_textBackGround.addChild(closeBtn);
		}
	}
}