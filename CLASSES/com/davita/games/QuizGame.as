/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.games {
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.ui.*;
	
	import com.davita.events.*;
	import com.davita.buttons.*;
	/**
	 *	All loaded swfs should have these properties and methods.
	 *	So all document classes except CourseWrapper should
	 *	inherit from QuizGame.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  22.02.2008
	 */
	public class QuizGame extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var _pageMask:Sprite = new Sprite();
		private var _background:Sprite = new Sprite();

		public var _myParent:MovieClip;
				
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function QuizGame(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			_myParent = parent.parent as MovieClip;

			drawBackground();
			maskPage();
		}
		
		/* =================== */
		/* = draw background = */
		/* =================== */
		
		private function drawBackground():void
		{
			_background.graphics.beginFill(0x86ACC6);
			_background.graphics.drawRect(0,0,1000,600);
			addChildAt(_background, 0);
		}
		
		/**
		 *	used in the constructor to add a mask to the coursefile in case the designer forgets
		 */
		private function maskPage():void
		{
			_pageMask.graphics.beginFill(0x000000);
			_pageMask.graphics.drawRect(0,.5,1000,599.5);
			addChild(_pageMask);
			this.mask = _pageMask;
		}
		
		/* =========================== */
		/* = course gating functions = */
		/* =========================== */
		
		public function gateCourse():void
		{
			if (_myParent)
			{
				_myParent.setCourseAsGated();
			}
		}
		
		
		public function openGate():void
		{
			if (_myParent)
			{
				_myParent.openGate();		
			}
		}
		
	}
	
}
