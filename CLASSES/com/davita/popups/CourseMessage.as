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

	public class CourseMessage extends MovieClip
	{
		private var _backGround:Sprite = new Sprite();
		private var _textBackGround:Sprite = new Sprite();
		
		private var textFormat:TextFormat = new TextFormat();	
		private var messageTxt:TextField = new TextField();
		
		public var closeBtn:DynamicButton = new DynamicButton(100, 30, 5, "Close");
		
		private var _message:String;

		public function CourseMessage(message:String)
		{
			this._message = message;
			TweenLite.to(this, .5, {alpha:1, onComplete:drawBackground});
		}
		
		private function drawBackground():void
		{
			_backGround.graphics.beginFill(0x000000);
			_backGround.graphics.drawRect(0,.5,1000,599.5);
			_backGround.alpha = 0;
			TweenLite.to(_backGround, 2, {alpha:.85, onComplete:drawTextBackground});
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
			textFormat.font = "gotham book";
			textFormat.size = 12;
			textFormat.leading = 5;
			textFormat.color = 0x000000;

			messageTxt.defaultTextFormat = textFormat;
			messageTxt.text = this._message;
			messageTxt.x = 10;
			messageTxt.y = 10;
			messageTxt.width = 285;
			messageTxt.multiline = true;
			messageTxt.wordWrap = true;
			messageTxt.autoSize = TextFieldAutoSize.LEFT;
			messageTxt.embedFonts = true;
			messageTxt.antiAliasType = AntiAliasType.ADVANCED;
			messageTxt.alpha = .0;
			
			TweenLite.to(messageTxt, 1, {alpha:1, onComplete:drawButton});
			_textBackGround.addChild(messageTxt);
			/*var embeddedFonts:Array = Font.enumerateFonts(false);
			embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);
			for each (var font:Font in embeddedFonts)
			{
				trace("font: " + font.fontName);
			}*/
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