/*
	RC_Channel.cpp - Radio library for Arduino
	Code by Jason Short. DIYDrones.com

	This library is free software; you can redistribute it and / or
		modify it under the terms of the GNU Lesser General Public
		License as published by the Free Software Foundation; either
		version 2.1 of the License, or (at your option) any later version.

*/

package com {

	public class APM_RC extends Object
	{
		// input channels from PPM encoder

		var pwm_channels:Array;
		var state:int = 0;

		public function APM_RC()
		{
			pwm_channels = new Array(8);
		}

		// set by SIM
	    public function set_PWM_channel(pwm:int, ch:int):void
		{
			pwm_channels[ch] = pwm;
			state = 1;
		}

		public function InputCh(ch:int):int
		{
			return  pwm_channels[ch];
		}

		public function getState():int
		{
			return state;
		}
	}
}
