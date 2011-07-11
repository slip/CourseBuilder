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
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	import com.davita.utilities.*;
	import com.davita.documents.*;
	
	/**
	 *  Search class provides the search panel
	 *	with search functionality.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  19.11.2007
	 */
	public class Search extends MovieClip
	{
		private var _courseXML:XML;
		private var _coursePages:XMLList;
		private var searchFormat:TextFormat = new TextFormat();	
		private var searchIntroTxt:TextField = new TextField();
		private var searchFieldTxt:TextField = new TextField();
		private var searchLabelTxt:TextField = new TextField();
		private var searchResultsTxt:TextField = new TextField();
		private var searchButton:Button = new Button();
		
		/**
		 *	@constructor
		 */
		public function Search()
		{
			// TODO: move this.y to coursewrapper
			this.y = 60;
						
			setUpTextFields();
			
			// event handlers
			searchButton.addEventListener(MouseEvent.CLICK, findKeyword);
			searchResultsTxt.addEventListener(TextEvent.LINK, handleLink);			
		}
		
		/**
		 *	sets up the text fields and adds them to the stage
		 */
		private function setUpTextFields():void {
			var textFieldX:int = 146;
			
			searchFormat.font = "Gotham Medium";
			searchFormat.size = 12;
			searchFormat.leading = 5;
			searchFormat.color = 0x000000;

			searchIntroTxt.defaultTextFormat = searchFormat;
			searchIntroTxt.text = "Welcome to the course search page. We've made every effort to make these courses as easy to search as your refrigerator.";
			searchIntroTxt.x = textFieldX;
			searchIntroTxt.y = 112;
			searchIntroTxt.width = 400;
			searchIntroTxt.multiline = true;
			searchIntroTxt.wordWrap = true;
			searchIntroTxt.autoSize = TextFieldAutoSize.LEFT;
			searchIntroTxt.embedFonts = true;
			searchIntroTxt.antiAliasType = AntiAliasType.ADVANCED;
			
			searchLabelTxt.defaultTextFormat = searchFormat;
			searchLabelTxt.text = "Search:";
			searchLabelTxt.x = textFieldX;
			searchLabelTxt.y = (searchIntroTxt.y)+(searchIntroTxt.height+40);
			searchLabelTxt.height = 20;
			searchLabelTxt.autoSize = TextFieldAutoSize.LEFT;
			searchLabelTxt.embedFonts = true;
			searchLabelTxt.antiAliasType = AntiAliasType.ADVANCED;			

			searchFieldTxt.defaultTextFormat = searchFormat;
			searchFieldTxt.x = (searchLabelTxt.x)+(searchLabelTxt.width+20);
			searchFieldTxt.y = searchLabelTxt.y;
			searchFieldTxt.border = true;
			searchFieldTxt.width = 300;
			searchFieldTxt.height = searchLabelTxt.height;
			searchFieldTxt.type = TextFieldType.INPUT;
			searchFieldTxt.embedFonts = true;
			searchFieldTxt.antiAliasType = AntiAliasType.ADVANCED;
			
			searchButton.label = "Search";
			searchButton.height = searchLabelTxt.height;
			searchButton.move((searchFieldTxt.x)+(searchFieldTxt.width+20), searchLabelTxt.y);
			
			searchResultsTxt.x = textFieldX;
			searchResultsTxt.y = (searchFieldTxt.y)+(searchFieldTxt.height+40);
			searchResultsTxt.width = 400;
			searchResultsTxt.multiline = true;
			searchResultsTxt.wordWrap = true;
			searchResultsTxt.defaultTextFormat = searchFormat;
			searchResultsTxt.embedFonts = true;
			searchResultsTxt.antiAliasType = AntiAliasType.ADVANCED;
			
			addChild(searchIntroTxt);
			addChild(searchLabelTxt);
			addChild(searchFieldTxt);
			addChild(searchButton);
			addChild(searchResultsTxt);
		}
		
		/**
		 *	receives the XML file and populates the Tree
		 *	@param xml - course xml file
		 */
		public function setXml(xml:XML):void
		{
			_courseXML = xml;
			_coursePages = _courseXML.children().children();
		}		
		
		/**
		 *	sends the pagenum to CourseWrapper.searchLoadPage(pagenum)
		 *	triggered by a clicked link in searchResultsTxt
		 */
		private function handleLink(event:TextEvent):void 
		{
			var linkContent:Array = event.text.split(",");
			if (linkContent[1] != null)
			{
				(this.parent as MovieClip).searchLoadPage(linkContent[1]);
			}
		}
		
		/**
		 *	searches the keywords attribute of each course page
		 *	@param	keyword	 the search term
		 */
		public function findKeyword(event:MouseEvent):void 
		{
			var searchString = searchFieldTxt.text;
			var pattern:RegExp = new RegExp(searchString, "i");
			var patternMatches:Array = new Array();
			
			// first check to see if the searchfield is empty
			if (searchString == "")
			{
				searchResultsTxt.text = "Enter a keyword in the search box before searching.";
			}
			else
			{
				// loop through the coursePages
				for each (var page in _coursePages)
				{	
					// see if the searchString regExes any keywords
					// and if it does, add that page to the patternMatches array
					if (pattern.exec(page.@keywords))
					{
						patternMatches.push([page.@title, page.@pagenum, page.@description]);
					}
				}
				// if we found at least one match
				if (patternMatches.length != 0)
				{
					// display the match(es)
					searchResultsTxt.htmlText = "";
					for each (var match:* in patternMatches)
					{
						// match[1] is the pagenum, match[0] is the title, match[2] is the description
						searchResultsTxt.htmlText += "<a href=\"event:handleLink," + match[1] + "\"><u>" + match[0] + "</u></a> - " + match[2] + "<br>";
					}
				}
				// if we found nothing, apologize
				else
				{
					searchResultsTxt.text = "Sorry, \"" + searchString + "\" could not be found in this course.";
				}
			}
		}
		
		
	}
}