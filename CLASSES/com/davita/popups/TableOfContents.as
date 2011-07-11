/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.popups 
{

	import flash.display.*;
	import flash.events.*;
	import fl.events.ListEvent;
	import flash.text.*;
    import com.davita.events.*;
	import com.yahoo.astra.fl.controls.treeClasses.*;
	
	/**
	 *	TableOfContents Class
	 *	receives XML from CourseWrapper
	 *	and populates a Tree.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  16.11.2007
	 */
	public class TableOfContents extends MovieClip 
	{
		public var courseTitle_txt:TextField = new TextField();
		public var courseDescription_txt:TextField = new TextField();
		public var pageTitle_txt:TextField = new TextField();
		public var pageDescription_txt:TextField = new TextField();
		
		private var _contentsFormat:TextFormat = new TextFormat();
		private var _titleFormat:TextFormat = new TextFormat();	
		private var _courseXML:XML;
		private var _coursePages:XMLList;

		/**
		 *	@Constructor
		 */
		public function TableOfContents()
		{
			setCourseTextFields();
			setPageTextFields();
		}
		
		/* ================== */
		/* = text functions = */
		/* ================== */
		
		private function setCourseTextFields():void 
		{			
			_contentsFormat.font = "Gotham Medium";
			_contentsFormat.size = 12;
			_contentsFormat.color = 0x000000;
            
			_titleFormat.font = "Gotham Medium";
			_titleFormat.size = 16;
			_titleFormat.color = 0xC32B4A;

			courseTitle_txt.defaultTextFormat = _titleFormat;
			courseTitle_txt.autoSize = TextFieldAutoSize.LEFT;
			courseTitle_txt.width = 320;
			courseTitle_txt.multiline = true;
			courseTitle_txt.wordWrap = true;
			courseTitle_txt.x = 510;
			courseTitle_txt.y = 110;
			courseTitle_txt.embedFonts = true;
			courseTitle_txt.antiAliasType = AntiAliasType.ADVANCED;		
			addChild(courseTitle_txt);
			
			courseDescription_txt.autoSize = TextFieldAutoSize.LEFT;
			courseDescription_txt.x = 510;
			courseDescription_txt.y = courseTitle_txt.y + (courseTitle_txt.height + 60);
			courseDescription_txt.width = 320;
			courseDescription_txt.defaultTextFormat = _contentsFormat;
			courseDescription_txt.multiline = true;
			courseDescription_txt.wordWrap = true;
			courseDescription_txt.embedFonts = true;
			courseDescription_txt.antiAliasType = AntiAliasType.ADVANCED;		
			addChild(courseDescription_txt);
		}


		private function setPageTextFields():void 
		{
			pageTitle_txt.defaultTextFormat = _titleFormat;
			pageTitle_txt.autoSize = TextFieldAutoSize.LEFT;
			pageTitle_txt.width = 320;
			pageTitle_txt.multiline = true;
			pageTitle_txt.wordWrap = true;
			pageTitle_txt.x = 510;
			pageTitle_txt.y = courseDescription_txt.y + (courseDescription_txt.height + 100);
			pageTitle_txt.embedFonts = true;
			pageTitle_txt.antiAliasType = AntiAliasType.ADVANCED;		
			addChild(pageTitle_txt);	

			pageDescription_txt.x = 510;
			pageDescription_txt.y = pageTitle_txt.y + (pageTitle_txt.height + 40);
			pageDescription_txt.width = 320;
			pageDescription_txt.defaultTextFormat = _contentsFormat;
			pageDescription_txt.multiline = true;
			pageDescription_txt.wordWrap = true;
			pageDescription_txt.embedFonts = true;
			pageDescription_txt.antiAliasType = AntiAliasType.ADVANCED;		
			addChild(pageDescription_txt);
			
		}
		/**
		 *	receives the XML file and populates the Tree
		 *	@param xml - course xml file
		 */
		public function setXml(xml:XML):void
		{   
			_courseXML = xml;
			_coursePages = _courseXML.children().children();
			courseTitle_txt.text = _courseXML.@title;
			courseDescription_txt.text = _courseXML.@description;
			tocTree.dataProvider = new TreeDataProvider(_courseXML);
			tocTree.labelField = "title";
			tocTree.addEventListener(ListEvent.ITEM_CLICK, showDescription);			
		};
		
		//
		// Event handlers
		//
		
		/**
		 *	handles the PAGE_CHANGED event
		 */
		public function updateToc(event:CourseEvent):void 
		{
			var pageNum:int = event.pageNum;
			pageTitle_txt.text = _coursePages[pageNum].@title;
			pageDescription_txt.text = _coursePages[pageNum].@description
		}
		
		/**
		 *	handles the ITEM_CLICK event sent by the tree
		 *	fills in the page title and description
		 */
		private function showDescription(event:ListEvent):void
		{
			if (event.item.description)
			{
				pageTitle_txt.text = event.item.title;				
				pageDescription_txt.text = event.item.description;
			}
		}
	}
}
