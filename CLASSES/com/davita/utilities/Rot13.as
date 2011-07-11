/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.utilities
{
	public class ROT13 {

		/**
		* Variables
		* @exclude
		*/
		private static var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMabcdefghijklmnopqrstuvwxyzabcdefghijklm";
	
		/**
		* Encodes or decodes a ROT13 string.
		*/
		// JH DotComIt 11/1/06 removed static
		public function calculate(src:String):String {
			var calculated:String = new String("");
			for (var i:Number = 0; i<src.length; i++) {
				var character:String = src.charAt(i);
				var pos:Number = chars.indexOf(character);
				if (pos > -1) character = chars.charAt(pos+13);
				calculated += character;
			}
			return calculated;
		}

	}
}