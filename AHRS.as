package com {
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;

	public class AHRS extends Location{

		public var roll_sensor:Number = 0;
		public var pitch_sensor:Number = 0;
		public var yaw_sensor:Number = 0;
		public var rotation_speed:Vector3D;
		public var gyro:Vector3D;
		public var omega:Vector3D;
		public var accel:Vector3D;
		public var dcm:Matrix3D;

		public function AHRS() {
			accel 			= new Vector3D(0,0,0);
			gyro 			= new Vector3D(0,0,0);
			rotation_speed 	= new Vector3D(0,0,0);
			omega 			= new Vector3D(0,0,0);
			dcm				= new Matrix3D();
		}

		public function init() {
			roll_sensor 	= 0;
			pitch_sensor 	= 0;
			yaw_sensor 		= 0;
			accel 			= new Vector3D(0,0,-9.805);
			gyro 			= new Vector3D(0,0,0);
			rotation_speed 	= new Vector3D(0,0,0);
			omega 			= new Vector3D(0,0,0);
			dcm				= new Matrix3D();
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




