package com.davita.documents
{
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import com.greensock.TimelineLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
public class FalconDemo	extends MovieClip
{
	
	public function FalconDemo()
	{
		super();
	}

	TweenPlugin.activate([GlowFilterPlugin, AutoAlphaPlugin, BlurFilterPlugin,TintPlugin, ColorTransformPlugin, VisiblePlugin]);

	public function textFadeIn(...movieClips):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:int=0; i < movieClips.length; i++)
		{
			timeline.append(TweenLite.from(movieClips[i], .35, {alpha:0,x:"-105",y:"-15", scaleX:2.5, scaleY:2.5, blurFilter:{blurX:20, blurY:20}}));
			timeline.append(TweenLite.to(movieClips[i], .25, {glowFilter:{color:0xffffff, alpha:1, blurX:8, blurY:8, strength:1, remove:true, delay:.5}}));
		}
	}
	
	public function headerFadeIn(...movieClips):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:int=0; i < movieClips.length; i++)
		{
			timeline.append(TweenLite.from(movieClips[i], .35, {alpha:0,x:"-105",y:"-15", scaleX:2.5, scaleY:2.5, blurFilter:{blurX:20, blurY:20}}));
			timeline.append(TweenLite.to(movieClips[i], .25, {glowFilter:{color:0xffffff, alpha:1, blurX:8, blurY:8, strength:1, remove:true, delay:.5}}));
			timeline.append(TweenLite.to(movieClips[i], .25, {alpha:.38, blurFilter:{blurX:10, blurY:10}, delay:3}));
			timeline.append(TweenLite.to(movieClips[i], .1, {autoAlpha:0, delay:.1}));
		}
	}

	public function textFadeOut(...movieClips):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:int=0; i < movieClips.length; i++)
		{
			var nestedTimeline:TimelineLite = new TimelineLite();
			nestedTimeline.append(TweenLite.to(movieClips[i], .25, {alpha:.38, blurFilter:{blurX:10, blurY:10}}));
			nestedTimeline.append(TweenLite.to(movieClips[i], .1, {autoAlpha:0}));
			timeline.append(nestedTimeline);
		}
	}
	
	public function screenIconFadeIn(movieClip:MovieClip):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		
		// define where the clip should end up
		var finalX:int = movieClip.x;
		var finalY:int = movieClip.y;
		
		// put the clip where it should begin
		movieClip.x = 175;
		movieClip.y = 81;
		movieClip.scaleX = 1.85;
		movieClip.scaleY = 1.85;

		timeline.append(TweenLite.from(movieClip, .5, {alpha:0,x:300,y:150, scaleX:.8, scaleY:.8, delay:.5}));
		timeline.append(TweenLite.to(movieClip, .5, {x:finalX, y:finalY, scaleX:1, scaleY:1, delay:.5}));
	}
	
	public function screenIconFadeOut(movieClip:MovieClip):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});		
		timeline.append(TweenLite.to(movieClip, .5, {alpha:0,x:238,y:108, scaleX:.8, scaleY:.8, delay:.2, blurFilter:{blurX:5, blurY:5}}));
	}
	
	public function screenBounceIn(mc:MovieClip):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		timeline.append(TweenLite.from(mc, 1, {y:-334, ease:Elastic.easeOut, blurFilter:{blurX:5, blurY:5}}));
	}

	public function mouseToAndClick(mc:MovieClip, positions:Array):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:uint = 0; i<positions.length; i++)
		{
			var subTimeline:TimelineLite = new TimelineLite();
			subTimeline.append(TweenLite.to(mc, 1, {x:positions[i][0],y:positions[i][1]}));
			subTimeline.append(TweenLite.to(mc, .1, {scaleX:.2, scaleY:.2}));
			subTimeline.append(TweenLite.to(mc, .1, {scaleX:.25, scaleY:.25}));
			subTimeline.append(TweenLite.delayedCall(0, hilite, [positions[i][0],positions[i][1]]));
			timeline.append(subTimeline);
		}
	}

	public function mouseToAndCheck(mc:MovieClip, positions:Array):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:uint = 0; i< positions.length ; i++)
		{
			var subTimeline:TimelineLite = new TimelineLite();
			subTimeline.append(TweenLite.to(mc, 1, {x:positions[i][0],y:positions[i][1]}));
			subTimeline.append(TweenLite.to(mc, .1, {scaleX:.2, scaleY:.2}));
			subTimeline.append(TweenLite.to(mc, .1, {scaleX:.25, scaleY:.25}));
			subTimeline.append(TweenLite.delayedCall(0, checkmark, [positions[i][0],positions[i][1],i]));
			subTimeline.append(TweenLite.delayedCall(0, hilite, [positions[i][0],positions[i][1]]));
			timeline.append(subTimeline);
		}
	}

	public function checkmark(xPos:int, yPos:int, num:uint):void
	{
		var checkmark:MovieClip = new CheckMark();
		checkmark.x = xPos;
		checkmark.y = yPos;
		checkmark.name = "checkmark"+num;
		this.addChild(checkmark);
	}
	
	public function hilite(xPos:int, yPos:int):void
	{
		var hilite:MovieClip = new MouseHilite();
		hilite.x = xPos;
		hilite.y = yPos;
		this.addChild(hilite);
	}

	public function removeCheckmarks():void
	{
		for (var i:int = 0; i< this.numChildren; i++)
		{
			if (this.getChildAt(i) is CheckMark) 
	        { 
	            this.removeChildAt(i);
	        }
		}
	}

	public function screenFromLeft(mc:MovieClip):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		timeline.append(TweenLite.from(mc, 1, {x:-427, alpha:0,ease:Elastic.easeOut, blurFilter:{blurX:5, blurY:5}}));
	}

	public function mainImageFadeIn(mc:MovieClip):void
	{
		mc.alpha = 0;
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		timeline.append(TweenLite.to(mc, .2, {alpha:.9, colorTransform:{tint:0xffffff, tintAmount:0.4}}));
		timeline.append(TweenLite.to(mc, .2, {alpha:1, colorTransform:{exposure:1.9}}));
		timeline.append(TweenLite.to(mc, .25, {alpha:.9, colorTransform:{exposure:1}}));
	}

	public function quickGlow(...movieClips):void
	{
		var timeline:TimelineLite = new TimelineLite({onComplete:play});
		for (var i:int=0; i < movieClips.length; i++)
		{
			timeline.append(TweenLite.to(movieClips[i], .2, {glowFilter:{color:0xffffff, alpha:1, blurX:8, blurY:8, strength:1, remove:true, delay:.1}}));
		}
	}
	
	public function makeInvisible(...movieClips):void
	{
		for (var i:int=0; i < movieClips.length; i++)
		{
			movieClips[i].alpha = 0;
		}
	}
	
}

}