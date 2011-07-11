package com.davita.sound
{
	import flash.events.Event;

	public class CuePointEvent extends Event
	{
		// PROPERTIES
		public static const CUE_POINT:String = "cuePoint";
		public var name:String;
		public var time:uint;

		// CONSTRUCTOR
		public function CuePointEvent(type:String, cuePointName:String, cuePointTime:uint, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.name = cuePointName;
			this.time = cuePointTime;
		}

		// METHODS
		// Clone
		public override function clone():Event
        {
			return new CuePointEvent(type, name, time, bubbles, cancelable);
		}
	}
}