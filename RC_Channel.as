/*
	RC_Channel.cpp - Radio library for Arduino
	Code by Jason Short. DIYDrones.com

	This library is free software; you can redistribute it and / or
		modify it under the terms of the GNU Lesser General Public
		License as published by the Free Software Foundation; either
		version 2.1 of the License, or (at your option) any later version.

*/

package com {
	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageDisplayState;

	import flash.display.DisplayObject;
    import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Vector3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.utils.*;

	import flash.text.TextField;
	import flash.ui.Keyboard;

	public class RC_Channel extends Object
	{
		public const RC_CHANNEL_ANGLE		:int = 0;
		public const RC_CHANNEL_RANGE		:int = 1;
		public const RC_CHANNEL_ANGLE_RAW	:int = 2;

		public var channel_num				:int = 0;

		public var radio_in					:Number = 0;
		public var control_in				:Number = 0;
		public var expo_in					:Number = 0;
		public var expo_LUT					:Array;
		public var expo_enabled				:Boolean = false;

		public var servo_out				:Number = 0;
		public var pwm_out					:Number = 0;
		public var radio_out				:Number = 0;

		public var radio_min				:Number = 1000;
		public var radio_trim				:Number = 1500;
		public var radio_max				:Number = 2000;

		public var scale_output				:Number = 1;

		public var _filter					:Boolean = false;
		public var _reverse					:Number = 1;
		public var _dead_zone				:Number = 0;
		public var _type					:Number = 0;

		public var _high					:int = 1;
		public var _low						:int = 0;

		public var _high_out				:int = 1;
		public var _low_out					:int = 0;

		public function RC_Channel()
		{
		}

		public function set_range(low:int, high:int):void
		{
			_type 		= RC_CHANNEL_RANGE;
			_high 		= high;
			_low 		= low;
			_high_out 	= high;
			_low_out 	= low;
		}


		public function set_range_out(low:int, high:int):void
		{
			_high_out 	= high;
			_low_out 	= low;
		}


		public function set_angle(angle:int):void
		{
			_type 		= RC_CHANNEL_ANGLE;
			_high 		= angle;
		}

		public function set_dead_zone(dzone:int):void
		{
			//_dead_zone.set_and_save(Math.abs(dzone >>1));
			_dead_zone = Math.abs(dzone >>1);
		}


		public function set_reverse(reverse:Boolean):void
		{
			if (reverse) _reverse = -1;
			else _reverse = 1;
		}


		public function get_reverse():Boolean
		{
			if (_reverse==-1) return true;
			else return false;
		}

		public function set_filter(filter:Boolean):void
		{
			_filter = filter;
		}


		public function set_type(t:int):void
		{
			_type = t;
			//Serial.print("type1: ");
			//Serial.println(t,DEC);
		}

		// call after first read
		public function trim():void
		{
			radio_trim = radio_in;
		}

		public function set_expo_LUT(lut:Array)
		{
			expo_LUT = lut;
			trace("did set lut")
		}

		// read input from APM_RC - create a control_in value
		public function set_pwm(pwm:Number):void
		{
			radio_in = pwm;

			if(_type == RC_CHANNEL_RANGE){
				control_in = pwm_to_range();
				//control_in = constrain(control_in, _low, _high);
				//control_in = Math.min(control_in, _high);
				control_in = (control_in < _dead_zone) ? 0 : control_in;

				if (Math.abs(scale_output) != 1){
					control_in *= scale_output;
				}

				if(expo_enabled){
					var tmp1, tmp2:int;
			   		tmp1 	= constrain(control_in, 0, 999);
			   		tmp2	= tmp1 / 100;   // 0:9
					control_in	= expo_LUT[tmp2] + (tmp1 - tmp2 * 100) * (expo_LUT[tmp2 + 1] - expo_LUT[tmp2]) / 100;
				}

			}else{

				//RC_CHANNEL_ANGLE, RC_CHANNEL_ANGLE_RAW
				control_in = pwm_to_angle();

				if (Math.abs(scale_output) != 1){
					control_in *= scale_output;
				}

				/*
				// coming soon ??
				if(expo) {
					long temp = control_in;
					temp = (temp * temp) / _high;
					control_in = (int)((control_in >= 0) ? temp : -temp);
				}*/
			}
		}

		public function control_mix(value:Number):Number
		{
			return (1 - Math.abs(control_in / _high)) * value + control_in;
		}

		// are we below a threshold?

		public function get_failsafe()
		{
			return (radio_in < (radio_min - 50));
		}

		// returns just the PWM without the offset from radio_min
		public function calc_pwm():void
		{
			if(_type == RC_CHANNEL_RANGE){
				pwm_out 	= range_to_pwm();
				//trace(pwm_out);
				radio_out 	= (_reverse >= 0) ? (radio_min + pwm_out) : (radio_max - pwm_out);

			}else if(_type == RC_CHANNEL_ANGLE_RAW){
				pwm_out 	= servo_out * .1;
				radio_out 	= (pwm_out * _reverse) + radio_trim;

			}else{ // RC_CHANNEL_ANGLE
				pwm_out 	= angle_to_pwm();
				radio_out 	= pwm_out + radio_trim;
			}

			radio_out = constrain(radio_out, radio_min, radio_max);
		}

		// ------------------------------------------


		/*
		public function load_eeprom():void
		{
			radio_min.load();
			radio_trim.load();
			radio_max.load();
			_reverse.load();
			_dead_zone.load();
		}

		public function save_eeprom():void
		{
			radio_min.save();
			radio_trim.save();
			radio_max.save();
			_reverse.save();
			_dead_zone.save();
		}
		*/

		// ------------------------------------------

		public function zero_min_max():void
		{
			radio_min = radio_max = radio_in;
		}


		public function update_min_max():void
		{
			radio_min = Math.min(radio_min, radio_in);
			radio_max = Math.max(radio_max, radio_in);
		}

		// ------------------------------------------

		public function pwm_to_angle():Number
		{
			var radio_trim_high	:int = radio_trim + _dead_zone;
			var radio_trim_low	:int = radio_trim - _dead_zone;

			// prevent div by 0
			if ((radio_trim_low - radio_min) == 0 || (radio_max - radio_trim_high) == 0)
				return 0;

			if(radio_in > radio_trim_high){
				return _reverse * (_high * (radio_in - radio_trim_high)) / (radio_max  - radio_trim_high);
			}else if(radio_in < radio_trim_low){
				return _reverse * (_high * (radio_in - radio_trim_low)) / (radio_trim_low - radio_min);
			}else
				return 0;
		}



		public function angle_to_pwm():Number
		{
			if((servo_out * _reverse) > 0)
				return _reverse * (servo_out * (radio_max - radio_trim)) / _high;
			else
				return _reverse * (servo_out * (radio_trim - radio_min)) / _high;
		}

		// ------------------------------------------


		public function pwm_to_range():Number
		{
			var r_in:int = constrain(radio_in, radio_min, radio_max);

			var radio_trim_low:int = radio_min + _dead_zone;

			if(r_in > radio_trim_low)
				return (_low + ((_high - _low) * (r_in - radio_trim_low)) / (radio_max - radio_trim_low));
			else if(_dead_zone > 0)
				return 0;
			else
				return _low_out;
		}


		public function range_to_pwm():Number
		{
			return ((servo_out - _low_out) * (radio_max - radio_min)) / (_high_out - _low_out);
		}

		// ------------------------------------------

		public function norm_input():Number
		{
			if(radio_in < radio_trim)
				return _reverse * (radio_in - radio_trim) / (radio_trim - radio_min);
			else
				return _reverse * (radio_in - radio_trim) / (radio_max  - radio_trim);
		}

		public function norm_output():Number
		{
			var mid:int = (radio_max + radio_min) / 2;

			if(radio_out < mid)
				return (radio_out - mid) / (mid - radio_min);
			else
				return (radio_out - mid) / (radio_max  - mid);
		}

		public function constrain(val:Number, min:Number, max:Number):Number
		{
			val = Math.max(val, min);
			val = Math.min(val, max);
			return val;
		}


	}
}


