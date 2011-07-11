/*
Copyright (c) 2010 Normal Software.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.davita.utilities
{
	import flash.display.*;
	import com.greensock.TweenLite;
	import com.greensock.TimelineLite;
    import com.greensock.easing.*;
    import com.greensock.plugins.*;
    TweenPlugin.activate([GlowFilterPlugin]);
	
	/**
	 *  CBAnimator is a collection of
	 *	different types of transitions.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Ian Kennedy
	 *	@since  04.07.2010
	 */
	public class CBAnimator
	{
		public function CBAnimator()
		{			
			super();
		}
		
		public function moveTo(xPos:Number, yPos:Number, duration:Number, delay:Number, ...movieClips):void
		{
			var timeline:TimelineLite = new TimelineLite();
			for (var i:int=0; i < movieClips.length; i++)
			{
				timeline.append(new TweenLite(movieClips[i], duration, {x:xPos, y:yPos}), delay);
			}
		}
		
		public function fadeIn(duration:Number, delay:Number, ...movieClips):void
		{
			var timeline:TimelineLite = new TimelineLite();
			for (var i:int=0; i < movieClips.length; i++)
			{
				movieClips[i].alpha = 0;
				timeline.append(new TweenLite(movieClips[i], duration, {alpha:1}), delay);
			}
		}
		
		public function fadeOut(duration:Number, delay:Number, ...movieClips):void
		{
			var timeline:TimelineLite = new TimelineLite();
			for (var i:int=0; i < movieClips.length; i++)
			{
				movieClips[i].alpha = 1;
				timeline.append(new TweenLite(movieClips[i], duration, {alpha:0}), delay);
			}
		}

	    public function smallToBig(duration:Number, delayInSeconds:Number, ...movieClips):void
        {
            var timeline:TimelineLite = new TimelineLite();
            for (var i:uint = 0; i < movieClips.length; i++) {
                timeline.append(TweenLite.from(movieClips[i], duration, {scaleX:0, scaleY:0, delay:delayInSeconds, ease:Elastic.easeOut}));
            }
        }
        
        public function bigToSmall(duration:Number, delayInSeconds:Number, ...movieClips):void
        {
            var timeline:TimelineLite = new TimelineLite();
            for (var i:uint = 0; i < movieClips.length; i++) {
                timeline.append(TweenLite.from(movieClips[i], duration, {scaleX:4, scaleY:4, alpha:0, delay:delayInSeconds, ease:Bounce.easeOut}));
            }
        }

        public function makeInvisible(...movieClips):void
        {
            for (var i:int=0; i < movieClips.length; i++)
            {
                movieClips[i].alpha = 0;
            }
        }
            
        public function glow(duration:Number, delayInSeconds:Number, myColor:String, ...movieClips):void
        {
            var timeline:TimelineLite = new TimelineLite();
            for (var i:uint = 0; i < movieClips.length; i++) {
                timeline.append(TweenLite.to(movieClips[i], duration, {glowFilter:{color:myColor, alpha:1, blurX:10, blurY:10}, ease:Quad.easeInOut, delay:delayInSeconds}));
            }
        }
        
        public function unGlow(duration:Number, delayInSeconds:Number, myColor:String, ...movieClips):void
        {
            var timeline:TimelineLite = new TimelineLite();
            for (var i:uint = 0; i < movieClips.length; i++) {
                timeline.append(TweenLite.to(movieClips[i], duration, {glowFilter:{color:myColor, alpha:1, blurX:0, blurY:0}, ease:Quad.easeInOut, delay:delayInSeconds}));
            }
        }
	}
}
