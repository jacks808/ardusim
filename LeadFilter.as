package com {
	public class LeadFilter
	{
		// takes velocity and position and outputs pos estimate
		//

		public var last_velocity:Number = 0;

		public function LeadFilter(){
		}

		public function get_position(pos:Number, vel:Number, dt:Number):Number
		{
			vel = (last_velocity + vel) / 2;
			var new_position:Number  = pos + vel;
			new_position += (vel - last_velocity);
			last_velocity = vel;
			return new_position;
		}
	}
}



