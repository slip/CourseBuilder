/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.elements {
	import flash.text.*;
	import fl.controls.CheckBox;
	
	/**
	 *	Class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Ian Kennedy
	 *	@since  24.03.2008
	 */
	public class MCCheckBox extends CheckBox {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private var labelFormat = new TextFormat("Gotham Book", "14");
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function MCCheckBox(){
			super();
		}
		
		override protected function drawTextFormat():void {
			textField.setTextFormat(labelFormat);
			textField.defaultTextFormat = labelFormat;
			//textField.embedFonts = true;
		}
	}
}
