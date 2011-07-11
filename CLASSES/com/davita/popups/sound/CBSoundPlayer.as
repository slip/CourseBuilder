/*
Copyright (c) 2009 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.popups.sound
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
    import flash.media.Sound;
	
	/**
	 *  The CBSoundPlayer class is used within a DaVita CourseWrapper
	 *	to display closed captions of audio (if any) playing in the
	 *	currently loaded CourseFile.
	 *	
	 * 	@langversion ActionScript 3
	 *
	 *	@author Ian Kennedy
	 *	@since  04.12.2010
	 */
	public class CBSoundPlayer extends MovieClip
	{	
		public var isVisible:Boolean = new Boolean();
        public var soundLoader:SoundLoader;

        private var playBtn:SimpleButton = player_mc.play_btn;
        private var pauseBtn:SimpleButton = player_mc.pause_btn;
        private var fwdBtn:SimpleButton = player_mc.fwd_btn;
        private var rewBtn:SimpleButton = player_mc.rew_btn;
        private var closeBtn:SimpleButton = player_mc.close_btn;
        private var progSlider:MovieClip = player_mc.progSlider_mc;
        private var captionTextField:TextField;

		public function CBSoundPlayer(mp:Sound, pl:SimpleButton, pa:SimpleButton, fwd:SimpleButton, rew:SimpleButton, cl:SimpleButton, ccText:TextField, slider:MovieClip, drag:MovieClip)
		{
            mp3 = mp;
            playBtn = pl;
            pauseBtn = pa;
            fwdBtn = fwd;
            rewBtn = rew;
            closeBtn = cl;
            captionTextField = ccText;
            progBar = slider;
            dragSlider = drag;

            soundLoader = new SoundLoader(mp, this);
		}
		
	}
}
