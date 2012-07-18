package com {
	public class LeadFilter
	{
		// takes velocity and position and outputs pos estimate
		//

		public var last_velocity:Number = 0;

		public function LeadFilter(){
		}

		public function init():void
		{
			last_velocity = 0;
		}

		public function get_position(pos:Number, vel:Number):Number
		{
			var acceleration:Number = vel - last_velocity;
			//trace(pos, vel, acceleration);

			last_velocity = vel;
			return pos + vel + acceleration;
		}

	}
}

/*
	   500  >
------|-----------------
------|-----|-----------

*/