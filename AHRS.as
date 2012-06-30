package com {
	import flash.geom.Vector3D;

	public class AHRS extends Location{

		public var roll_sensor:Number = 0;
		public var pitch_sensor:Number = 0;
		public var yaw_sensor:Number = 0;
		public var rotation_speed:Vector3D;
		public var omega:Vector3D;
		public var accel:Vector3D;

		public function AHRS() {
			accel 			= new Vector3D(0,0,0);
			rotation_speed 	= new Vector3D(0,0,0);
			omega 			= new Vector3D(0,0,0);
		}

		public function init() {
			roll_sensor 	= 0;
			pitch_sensor 	= 0;
			yaw_sensor 		= 0;
			omega.x			= 0;
			omega.y			= 0;
			omega.z			= 0;
			rotation_speed.x	= 0;
			rotation_speed.y	= 0;
			rotation_speed.z	= 0;
			accel.x 		= 0;
			accel.y 		= 0;
			accel.z 		= 0;
		}

		public function addToRoll(r:Number) {
			roll_sensor 	+= r;
			roll_sensor = wrap_180(roll_sensor);
		}

		public function wrap_180(error:Number):Number
		{
			if (error > 18000)	error -= 36000;
			if (error < -18000)	error += 36000;
			return error;
		}

	}
}




