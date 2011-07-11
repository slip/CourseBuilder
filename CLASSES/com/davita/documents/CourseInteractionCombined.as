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
	import com.greensock.TimelineLite;
	import fl.motion.easing.*;
	import flash.text.*;	
	
	import com.davita.events.*;
	import com.davita.buttons.*;
	import com.davita.elements.Arrow;
	import com.davita.popups.GenericPopup;
	
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
	public dynamic class CourseInteractionCombined extends CourseSwf
	{
		public var interactions:Array = new Array();
		
		/**
		 *	constructor
		 */
		public function CourseInteractionCombined()
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
		
		private function removePopups():void 
		{
			for (var i:int = 0; i<this.numChildren; i++)
			{
				trace(getChildAt(i).name);
				if (this.getChildAt(i) is GenericPopup) 
		        { 
					trace(getChildAt(i));
		            this.removeChildAt(i);
		        }
			}
		}
		
		function traceDisplayList(container:DisplayObjectContainer, indentString:String = ""):void 
		{ 
		    var child:DisplayObject; 
		    for (var i:uint=0; i < container.numChildren; i++) 
		    { 
		        child = container.getChildAt(i); 
		        trace(indentString, child, child.name);  
		        if (container.getChildAt(i) is DisplayObjectContainer) 
		        { 
		            traceDisplayList(DisplayObjectContainer(child), indentString + "    ") 
		        } 
		    } 
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			/*traceDisplayList(this);*/
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
					removePopups();
					this.play();
					interactions.push(this.currentFrame);
					SoundMixer.stopAll();
				break;

				case "FalconContinueBtn" :
					removePopups();
					this.play();
					interactions.push(this.currentFrame);
					SoundMixer.stopAll();
				break;

				case "CorrectBtn01" :
					removePopups();
					this.play();
					interactions.push(this.currentFrame);
					SoundMixer.stopAll();
				break;

				case "CorrectBtn02" :
					removePopups();
					this.play();
					interactions.push(this.currentFrame);
					SoundMixer.stopAll();
				break;
				
				case "BackBtn01" :
					removePopups();
					this.gotoAndPlay(interactions.pop());
				break;
				
				case "BackBtn02" :
					removePopups();
					this.gotoAndPlay(interactions.pop());
				break;

				case "BackBtnFalcon01" :
					removePopups();
					this.gotoAndPlay(interactions.pop());
				break;
				
				case "BackBtnFalcon02" :
					removePopups();
					this.gotoAndPlay(interactions.pop());
				break;

				default:
					//trace("other thing clicked");
			}
			}
		}
	}
}
