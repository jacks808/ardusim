﻿package com {	import com.Location;	import flash.geom.Point;	public class Sonar extends Location{		public var altitude:Number = 0;		public var _copter_loc:Location;		public function Sonar(copter_loc:Location) {			_copter_loc = copter_loc;		}        public function read():Number		{			return constrain(_copter_loc.alt, 30, 700);        }		public function constrain(val:Number, min:Number, max:Number) :Number		{			val = Math.max(val, min);			val = Math.min(val, max);			return val;		}	}}