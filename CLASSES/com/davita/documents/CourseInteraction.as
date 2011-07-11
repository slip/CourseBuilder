/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.SoundMixer;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import flash.text.*;	
	
	import com.davita.events.*;
	import com.davita.buttons.*;
	import com.davita.elements.Arrow;
	
	import flash.utils.*;
	/**
	 *  base class for davita standard course interaction files.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  15.11.2007
	 */
	public dynamic class CourseInteraction extends CourseSwf
	{
		public var interactions:Array = new Array();
		
		/**
		 *	constructor
		 */
		public function CourseInteraction()
		{	
			super();		
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 *	create _myParent variable, retrieves _reviewInfo and
		 *	calls populateReviewTxt()
		 */
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_myParent = parent.parent as MovieClip;
			this.hasAudio = false;
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			/*trace(getQualifiedClassName(event.target));*/
			if (!getQualifiedClassName(event.target))
			{
				// do nothing
			} 
			else
			{
			switch (getQualifiedClassName(event.target)){
				case "IncorrectButton" :
					hint_mc.play();
				break;
				case "ContinueBtn" :
					this.play();
					removeChild(event.target);
					interactions.push(this.currentFrame);
					SoundMixer.stopAll();
				break;
				case "Continue" :
					removeChild(event.target);
					interactions.push(this.currentFrame);
				break;

				case "CorrectBtn01" :
					removeChild(event.target);
					interactions.push(this.currentFrame);
				break;

				case "CorrectBtn02" :
					removeChild(event.target);
					interactions.push(this.currentFrame);
				break;
				
				case "CorrectBtn" :
					removeChild(event.target);
					interactions.push(this.currentFrame);
				break;

				case "BackBtn" :
					this.gotoAndPlay(interactions.pop());
				break;
				
				case "BackBtn01" :
					this.gotoAndPlay(interactions.pop());
				break;
				
				case "BackBtn02" :
					this.gotoAndPlay(interactions.pop());
				break;

				case "CloseBtn" :
					removeChild(event.target.parent);
				break;

				case "TownCrierBtn" :
					var townCrierPopup:TownCrierPopup = new TownCrierPopup();
					this.addChild(townCrierPopup);
				break;

				case "DavitaWayBtn" :
					var davitaWayPopup:DavitaWayPopup = new DavitaWayPopup();
					this.addChild(davitaWayPopup);
				break;

				case "ThinkAboutBtn" :
					var thinkAboutPopup:ThinkAboutPopup = new ThinkAboutPopup();
					this.addChild(thinkAboutPopup);
				break;

				default:
					//trace("other thing clicked");
			}
			}
		}
	}
}