/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.buttons {
	import flash.geom.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.filters.*;
	
	/**
	 *	Class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  23.02.2008
	 */
	public class DynamicButton extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		// FEEL FREE TO CHANGE THESE VALUES, AS THE REST OF THE CODE WILL ADAPT
		var radius:int;        // The corners of your button
		var btnW:int;         // Button Width
		var btnH:int;         // Button Height
		var colors:Array = [0xE26C44, 0xE8B04A];    // The main gradient of your button
		var strID:String;  // Button Label
		var intX:int = 0;           // X-Position of your button's upper-left corner
		var intY:int = 0;           // Y-Position of your button's upper-left corner
    
		// PLAY WITH THESE AT YOUR RISK
		var fillType:String = GradientType.LINEAR;
		var alphas:Array = [100, 100];
		var ratios:Array = [0, 245];
    
		// TRY TO LEAVE EVERYTHING ELSE ALONE...
		var matr:Matrix = new Matrix();
		var spreadMethod:String = SpreadMethod.PAD;
    
		var myButton:MovieClip = new MovieClip();
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function DynamicButton(w:int, h:int, r:int, str:String)
		{
			super();
						
			this.btnW = w;
			this.btnH = h;
			this.radius = r;
			this.strID = str;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.buttonMode = true;
			this.tabEnabled = false;
			this.addEventListener(MouseEvent.ROLL_OVER, over);
			this.addEventListener(MouseEvent.ROLL_OUT, out);
			this.addEventListener(MouseEvent.CLICK, click);
			
			matr.createGradientBox( btnW, btnH, 90/180*Math.PI, 0, 0 );
			this.addChild( myButton );

			myButton.x = intX;
			myButton.y = intY;


			// BUTTON BACKGROUND
			var buttonBkg:Sprite = new Sprite();
			buttonBkg.graphics.lineStyle(0, 0xE88A41, 100, true, "none", "square", "round");
			buttonBkg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod );
			buttonBkg.graphics.moveTo(radius, 0);
			buttonBkg.graphics.lineTo((btnW-radius), 0);
			buttonBkg.graphics.curveTo(btnW, 0, btnW, radius);
			buttonBkg.graphics.lineTo(btnW, (btnH-radius));
			buttonBkg.graphics.curveTo(btnW, btnH, (btnW-radius), btnH);
			buttonBkg.graphics.lineTo(radius, btnH);
			buttonBkg.graphics.curveTo(0, btnH, 0, (btnH-radius));
			buttonBkg.graphics.lineTo(0, radius);
			buttonBkg.graphics.curveTo(0, 0, radius, 0);
			buttonBkg.graphics.endFill();

			// ADD THE BUTTON BACKGROUND TO THE FANCY BUTTON ONLY AFTER IT'S READY
			myButton.addChild( buttonBkg );

			// THE SHINY GLASSY EFFECT
			var shineRadius:Number = radius * 2 / 3;
			var shineW:Number = btnW - ( 0.0333 * btnW );
			var shineH:Number = btnH / 2 - ( 0.0667 * btnH );
			var shineFillType:String = GradientType.LINEAR;
			var shineColors:Array = [0xFFFFFF, 0xFFFFFF];
			var shineAlphas:Array = [70, 0];
			var shineRatios:Array = [0, 255];
			var shineMatr:Matrix = new Matrix();
			shineMatr.createGradientBox( shineW, shineH, 90/180*Math.PI, 0, 0 );
			var shine:Sprite = new Sprite();
			shine.x = ( 0.0333 * btnW ) / 2;
			shine.y = ( 0.0667 * btnH ) / 2;
			shine.graphics.lineStyle(0, 0xFFFFFF, 0);
			shine.graphics.beginGradientFill(shineFillType, shineColors, shineAlphas, shineRatios, shineMatr, spreadMethod );
			shine.graphics.moveTo(shineRadius, 0);
			shine.graphics.lineTo((shineW-shineRadius), 0);
			shine.graphics.curveTo(shineW, 0, shineW, shineRadius);
			shine.graphics.lineTo(shineW, (shineH-shineRadius));
			shine.graphics.curveTo(shineW, shineH, (shineW-shineRadius), shineH);
			shine.graphics.lineTo(shineRadius, shineH);
			shine.graphics.curveTo(0, shineH, 0, (shineH-shineRadius));
			shine.graphics.lineTo(0, shineRadius);
			shine.graphics.curveTo(0, 0, shineRadius, 0);
			shine.graphics.endFill();

			// ADD THE SHINY PART TO THE BUTTON ONLY AFTER IT'S BEEN GENERATED
			myButton.addChild( shine );

			// TEXT FORMAT FOR THE BUTTON LABEL
			var myFormat:TextFormat = new TextFormat();
			myFormat.align = "left";
			myFormat.font = "gotham book";
			myFormat.size = 16;
			myFormat.bold = true;
			myFormat.color = 0xFFFFFF;

			// THE BUTTON LABEL
			var labelText:TextField = new TextField();
			labelText.x = ( 0.5 * btnW ) / 2;
			labelText.y = ( 0.25 * btnH );
			labelText.text = strID;
			labelText.embedFonts = true;
			labelText.selectable = false;
			labelText.type = TextFieldType.DYNAMIC;
			labelText.autoSize = TextFieldAutoSize.LEFT;
			labelText.antiAliasType = "advanced";
			labelText.setTextFormat( myFormat );
			labelText.filters=[new DropShadowFilter(2,45,0,.85,2,2,.7,BitmapFilterQuality.HIGH)];
			
			// ADD THE TEXTFIELD ONLY AFTER IT'S COMPLETE
			myButton.addChild ( labelText );
		}

		function over(event:MouseEvent):void
		{
			this.filters=[new DropShadowFilter(0,45,0,.85,8,8,.7,BitmapFilterQuality.HIGH)];
		}
		
		function out(event:MouseEvent):void
		{
			this.filters=[];
		}
		
		function click(event:MouseEvent):void
		{

		}
		
	}
	
}
