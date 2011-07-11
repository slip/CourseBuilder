/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.documents
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import com.davita.utilities.*;
	import com.davita.documents.*;

	/**
	 *base class for course "review"
	 *
	 *@langversion ActionScript 3.0
	 *@playerversion Flash 9.0
	 *
	 *@author Ian Kennedy
	 *@since  26.11.2007
	 */
	public class CourseReview extends CourseSwf
	{
		public var _parent:MovieClip;
		public var reviewInfo:Array;
		
		private var answeredCorrectly:Array = new Array();
		private var answeredCorrectlyAfterOneTry:Array = new Array();
		private var answeredIncorrectly:Array = new Array();
				
		private var reviewFormat:TextFormat = new TextFormat();
		private var reviewIntroTxt:TextField = new TextField();
		private var reviewTxt:TextField = new TextField();

		private var almostCorrectKeywords:Array = new Array();
		private var incorrectKeywords:Array = new Array();
		private var coursePageKeywords:Array = new Array();

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *@Constructor
		 */
		public function CourseReview()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 *	create _parent variable, retrieves _reviewInfo and
		 *	calls populateReviewTxt()
		 */
		private function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_parent = parent.parent as MovieClip;
			reviewInfo = this._parent._reviewInfo;
			hasAudio = false;
			setUpTextFields();
			sortReviewInfo();
			matchKeywords();
			populateReviewTxt();
		};
		
		private function sortReviewInfo():void
		{
			// reviewInfo example:
			// [pageNumber[0], tries[1], page title[2],question[3], keywords...]
			for each (var review:* in reviewInfo)
			{
				var tries:int = review[1];
				if (tries == 0)
				{
					answeredCorrectly.push(review[2]);
				}
				else if (tries == 1)
				{
					answeredCorrectlyAfterOneTry.push(review);
				}
				else if (tries == 2)
				{
					answeredIncorrectly.push(review);
				}
			}
		};

		/**
		 *	match keywords in almostCorrectAnswer and incorrectAnswer
		 *	to the keywords attribute in this._parent.xmlPages
		 *	and populate this._parent.almostCorrectReviewPages with the
		 *	xmlPages title and pagenum attributes
		 */
		private function matchKeywords():Array
		{
			//populate the almostCorrectKeywords
			for each (var almostCorrectAnswer:* in answeredCorrectlyAfterOneTry)
			{
				for each (var item:* in almostCorrectAnswer.splice(4))
				{
					almostCorrectKeywords.push(item);
				}
			}

			//populate the incorrectKeywords
			for each (var incorrectAnswer:* in answeredIncorrectly)
			{
				for each (var item:* in incorrectAnswer.splice(4))
				{
					incorrectKeywords.push(item);
				}
			}
			
			// populate coursePageKeywords
			for each (var coursePage:* in this._parent.xmlPages)
			{
				for each (var word:* in coursePage.@keywords.split(","))
				{
					var coursePageInfo:Array = [coursePage.@title, coursePage.@pagenum];
					if (almostCorrectKeywords.indexOf(word) != -1)
					{
						ArrayUtilities.addDistinct(this._parent.almostCorrectReviewPages, coursePageInfo);
						/*this._parent.almostCorrectReviewPages.addDistinct([coursePage.@title, coursePage.@pagenum]);*/
					}
					if (incorrectKeywords.indexOf(word) != -1)
					{
						ArrayUtilities.addDistinct(this._parent.incorrectReviewPages, coursePageInfo);
					}
				}
			}
			return coursePageKeywords;
		};

		/**
		 *	loops over this._parent.almostCorrectReviewPages and creates text
		 *	for the revewTxt textfield.
		 */
		private function populateReviewTxt():void
		{
			if (answeredCorrectly.length != 0)
			{
				reviewTxt.htmlText = "<b>Answered Correctly:</b>";

				for each (var correctAnswer:* in answeredCorrectly)
				{
					reviewTxt.htmlText += "<p>"+correctAnswer+"</p>";
				}
				reviewTxt.htmlText += "<br/>"
			}
			
			if (answeredCorrectlyAfterOneTry.length != 0)
			{
				reviewTxt.htmlText += "<b>Answered with a little help and may need to review:</b>";
				for each (var almostCorrectAnswer:* in answeredCorrectlyAfterOneTry)
				{					
					reviewTxt.htmlText += "<p>"+almostCorrectAnswer[2]+"</p>";
					reviewTxt.htmlText += "<p><i>Review pages:</i></p>"
					for each (var almostCorrectReviewPage:* in this._parent.almostCorrectReviewPages)
					{
						reviewTxt.htmlText += "<a href=\"event:handleLink," + almostCorrectReviewPage[1] + "\"><u>" + almostCorrectReviewPage[0] + "</u></a>";
					}
				}
				reviewTxt.htmlText += "<br/>"				
			}

			if (answeredIncorrectly.length != 0)
			{
				reviewTxt.htmlText += "<b>Answered incorrectly and need to review:</b>";
				for each (var incorrectAnswer:* in answeredIncorrectly)
				{					
					reviewTxt.htmlText += "<p>"+incorrectAnswer[2]+"</p>";
					reviewTxt.htmlText += "<p><i>Review pages:</i></p>"
					for each (var incorrectReviewPage:* in this._parent.incorrectReviewPages)
					{
						reviewTxt.htmlText += "<a href=\"event:handleLink," + incorrectReviewPage[1] + "\"><u>" + incorrectReviewPage[0] + "</u></a>";
					}
				}
			}
		}

		private function handleLink(event:TextEvent):void 
		{
			var linkContent:Array = event.text.split(",");
			/*trace("linkContent[0]: " + linkContent[0] + ", linkContent[1]: "+linkContent[1]);*/
			if (linkContent[1] != null)
			{
				this._parent.loadPage(linkContent[1]-1);
			}
		}
				
		/**
		 *	puts textfields on the stage and formats them.
		 */
		private function setUpTextFields():void
		{
			addEventListener(TextEvent.LINK, handleLink);
			var textFieldX:int=146;

			reviewFormat.font="Gotham Book";
			reviewFormat.size=12;
			reviewFormat.leading=5;
			reviewFormat.color=0x000000;

			reviewIntroTxt.defaultTextFormat=reviewFormat;
			reviewIntroTxt.text="Welcome to the course review page. We've made every effort to make these courses as easy to review as your refrigerator.";
			reviewIntroTxt.x=textFieldX;
			reviewIntroTxt.y=112;
			reviewIntroTxt.width=600;
			reviewIntroTxt.multiline=true;
			reviewIntroTxt.wordWrap=true;
			reviewIntroTxt.autoSize=TextFieldAutoSize.LEFT;
			reviewIntroTxt.selectable = false;

			reviewTxt.defaultTextFormat=reviewFormat;
			reviewTxt.text="";
			reviewTxt.x=textFieldX;
			reviewTxt.y=reviewIntroTxt.y + reviewIntroTxt.height + 40;
			reviewTxt.width=600;
			reviewTxt.multiline=true;
			reviewTxt.wordWrap=true;
			reviewTxt.autoSize=TextFieldAutoSize.LEFT;
			reviewTxt.selectable = false;

			addChild(reviewIntroTxt);
			addChild(reviewTxt);
		}
	}
}