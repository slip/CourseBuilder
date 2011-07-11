package com.davita.sound
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class SoundSync extends Sound
	{

		// PROPERTIES
		private var _cuePoints:Array;
		private var _currentCuePoint:uint;
		private var _timer:Timer;
		private var _timerInterval:uint;
		private var _startTime:Number;
		private var _loops:uint;
		private var _soundChannel:SoundChannel;

		// CONSTRUCTOR
		public function SoundSync(stream:URLRequest = null, context:SoundLoaderContext = null) {
			super(stream, context);
			init();
		}

		// METHODS
		// init
		private function init():void {
			_cuePoints = new Array();
			_currentCuePoint = 0;
			_timerInterval = 50;
			_startTime = 0.0;
		}
		// Add Cue Point
		public function addCuePoint(cuePointName:String, cuePointTime:uint):void {
			_cuePoints.push(new CuePointEvent(CuePointEvent.CUE_POINT, cuePointName, cuePointTime));
			_cuePoints.sortOn("time", Array.NUMERIC);
		}
		// Get Cue Point
		public function getCuePoint(nameOrTime:Object):Object {
			var counter:uint = 0;
			while (counter < _cuePoints.length) {
				if (typeof(nameOrTime) == "string") {
					if (_cuePoints[counter].name == nameOrTime) {
						return _cuePoints[counter];
					}
				} else if (typeof(nameOrTime) == "number") {
					if (_cuePoints[counter].time == nameOrTime) {
						return _cuePoints[counter];
					}
				}
				counter++;
			}
			return null;
		}
		// Get Current Cue Point Index
		private function getCurrentCuePointIndex(cuePoint:CuePointEvent):uint {
			var counter:uint = 0;
			while (counter < _cuePoints.length) {
				if (_cuePoints[counter].name == cuePoint.name) {
					return counter;
				}
				counter++;
			}
			return null;
		}
		// Get Next Cue Point Index
		private function getNextCuePointIndex(milliseconds:Number):uint {
			if (isNaN(milliseconds)) {
				milliseconds = 0;
			}
			var counter:uint = 0;
			while (counter < _cuePoints.length) {
				if (_cuePoints[counter].time >= milliseconds) {
					return counter;
				}
				counter++;
			}
			return null;
		}
		// Remove Cue Point
		public function removeCuePoint(cuePoint:CuePointEvent):void {
			_cuePoints.splice(getCurrentCuePointIndex(cuePoint), 1);
		}
		// Remove All Cue Points
		public function removeAllCuePoints():void {
			_cuePoints = new Array();
		}
		// Play
		public override function play(startTime:Number = 0.0, loops:int=0, sndTransform:SoundTransform=null):SoundChannel {
			_soundChannel = super.play(startTime, loops, sndTransform);
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			dispatchEvent(new Event("play"));
			// Reset current cue point
			_startTime = startTime;
			_loops = 0; // our loops is different
			_currentCuePoint = getNextCuePointIndex(startTime);
			// Poll for cue points
			_timer = new Timer(_timerInterval);
			_timer.addEventListener(TimerEvent.TIMER, pollCuePoints);
			_timer.start();
			return _soundChannel;
		}
		// Stop
		public function stop():void {
			_soundChannel.stop();
			dispatchEvent(new Event("stop"));
			// Kill polling
			_timer.stop();
		}
		// Poll Cue Points
		private function pollCuePoints(event:TimerEvent):void {
			var time:Number = _cuePoints[_currentCuePoint].time + (length * _loops);
			var span:Number = 0;
			if (_cuePoints[_currentCuePoint + 1] == undefined) {
				span = time + _timerInterval * 2;
			} else {
				span = _cuePoints[_currentCuePoint + 1].time + (length * _loops);
			};
			if (_soundChannel.position >= time && _soundChannel.position <= span) {
				// Dispatch event
				dispatchEvent(_cuePoints[_currentCuePoint]);
				// Advance to next cue point ...
				if (_currentCuePoint < _cuePoints.length - 1) {
					_currentCuePoint++;
				} else {
					_currentCuePoint = getNextCuePointIndex(_startTime);
					_loops++;
				}
			}
		}
		// EVENT HANDLERS
		// onSoundComplete
		public function onSoundComplete(event:Event):void {
			// Reset current cue point
			_currentCuePoint = 0;
			// Kill polling
			_timer.stop();
			// Dispatch event
			dispatchEvent(new Event(Event.SOUND_COMPLETE));
		}
	}
}