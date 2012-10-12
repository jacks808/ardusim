package com {

	//import caurina.transitions.Tweener;

	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageDisplayState;

	import flash.display.DisplayObject;
    import flash.events.*;
	import flash.geom.*;

    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.utils.*;

    import flash.display.StageScaleMode;

	import flash.text.TextField;
	import flash.ui.Keyboard;
	import com.Location;
	import com.Wind;
	import com.AHRS;
	import com.Parameters;
	import com.AP_RC;
	import com.AverageFilter;

	public class Copter_hexa extends Object
	{
		public var ahrs						:AHRS;
		public var loc						:Location;
		public var g						:Parameters;
		public var APM_RC					:AP_RC;
		public var motor_filter_0			:AverageFilter;
		public var motor_filter_1			:AverageFilter;
		public var motor_filter_2			:AverageFilter;
		public var motor_filter_3			:AverageFilter;
		public var motor_filter_4			:AverageFilter;
		public var motor_filter_5			:AverageFilter;
		public var drag						:Vector3D;		//
		public var airspeed					:Vector3D;		//
		//public var thrust					:Vector3D;		//
		public var position					:Vector3D;		//
		public var velocity					:Vector3D;
		//public var velocity_old				:Vector3D;
		public var wind						:Point;			//
		public var rot_accel				:Vector3D;			//
		public var angle3D					:Vector3D;			//
		public var windGenerator			:Wind;			//
		public var edf						:int = 0;			//

		private var screen3d				:Matrix3D;

		public var gravity					:Number 	= 980.5;
		public var thrust_scale				:Number 	= 0.4;
		public var throttle					:Number		= 500;
		public var rotation_bias			:Number 	= 1;
		private var _jump_z					:Number 	= 0;

		private var v3:Vector.<Vector3D>;

		public function Copter_hexa():void
		{
			loc = new Location();
			//addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			windGenerator = new Wind();
			g = Parameters.getInstance();
			screen3d = new Matrix3D();
			screen3d.appendRotation(90, Vector3D.Z_AXIS);	// Yaw
	    }

	    public function addedToStage(even:Event) : void
		{
			//g = Parameters.getInstance();
		}

	    public function init():void
		{
			drag 			= new Vector3D(0,0,0);
			airspeed 		= new Vector3D(0,0,0);

			wind 			= new Point(0,0);
			position 		= new Vector3D(0,0,0);
			velocity 		= new Vector3D(0,0,0);
			angle3D			= new Vector3D(0,0,1);
			rot_accel		= new Vector3D(0,0,0);
			//velocity_old 	= new Vector3D(0,0,0);

			v3 = new Vector.<Vector3D>(3);

			setThrottleCruise(throttle);
			loc.lat = 0;
			loc.lng = 0;
			loc.alt = 0;
		}

		public function setThrottleCruise(c:Number):void
		{
			thrust_scale = (g.mass * gravity) / (6 * c); // 4 motors
			motor_filter_0	= new AverageFilter(g.esc_delay);
			motor_filter_1	= new AverageFilter(g.esc_delay);
			motor_filter_2	= new AverageFilter(g.esc_delay);
			motor_filter_3	= new AverageFilter(g.esc_delay);
			motor_filter_4	= new AverageFilter(g.esc_delay);
			motor_filter_5	= new AverageFilter(g.esc_delay);
			motor_filter_0.force_sample(c);
			motor_filter_1.force_sample(c);
			motor_filter_2.force_sample(c);
			motor_filter_3.force_sample(c);
			motor_filter_4.force_sample(c);
			motor_filter_5.force_sample(c);
		}

		public function jump():void
		{
			_jump_z -= 5000;

		}

		public function update(dt:Number):void
		{
			var _thrust	:Number = 0;
			rot_accel = new Vector3D(0,0,0);
			angle3D.x = 0
			angle3D.y = 0;
			angle3D.z = 1;

			wind = windGenerator.read();

			// ESC's moving average filter
			var motor_output:Array = new Array(6);
			motor_output[0] = motor_filter_0.apply(APM_RC.get_motor_output(0));
			motor_output[1] = motor_filter_1.apply(APM_RC.get_motor_output(1));
			motor_output[2] = motor_filter_2.apply(APM_RC.get_motor_output(2));
			motor_output[3] = motor_filter_3.apply(APM_RC.get_motor_output(3));
			motor_output[4] = motor_filter_4.apply(APM_RC.get_motor_output(4));
			motor_output[5] = motor_filter_5.apply(APM_RC.get_motor_output(5));

/*
		2

	1		0

		3



		3	5

	2			1

		6	4


*/

			/*trace("MOT, "+
						(1028 + Math.floor(motor_output[0]))	+", "+
						(1028 + Math.floor(motor_output[1]))	+", "+
						(1028 + Math.floor(motor_output[2])) 	+", "+
						(1028 + Math.floor(motor_output[3])) 	);
			*/

			// setup motor rotations

			///*
			rot_accel.x  		+= g.motor_kv  * motor_output[2] * .5;	// 3 roll top left
			rot_accel.x  		+= g.motor_kv  * motor_output[1];		// 2 roll left
			rot_accel.x  		+= g.motor_kv  * motor_output[5] * .5;	// 6 roll bot left

			rot_accel.x  		-= g.motor_kv  * motor_output[4] * .5;	// 5 roll top right
			rot_accel.x 		-= g.motor_kv  * motor_output[0]; 		// 1 roll right
			rot_accel.x  		-= g.motor_kv  * motor_output[3] * .5;	// 4 roll bot right
			//*/

			///*
			rot_accel.y  		+= g.motor_kv  * motor_output[2] * .866;	// 3 pitch top left
			rot_accel.y  		-= g.motor_kv  * motor_output[5] * .866;	// 6 pitch bot left

			rot_accel.y  		+= g.motor_kv  * motor_output[4] * .866;	// 5 pitch top right
			rot_accel.y  		-= g.motor_kv  * motor_output[3] * .866;	// 4 pitch bot right

			/*
			//left side
			motor_out[CH_3]		= + pitch_out;	// CW Front
			motor_out[CH_6]     = - pitch_out;	// CW Back

			//right side
			motor_out[CH_5] 	= + pitch_out;	// CCW Front
			motor_out[CH_4] 	= - pitch_out;	// CCW Back
			*/

			rot_accel.z  		-= g.motor_kv  * motor_output[0] * .08; 	// CW 1
			rot_accel.z  		-= g.motor_kv  * motor_output[2] * .08;		// CW 3
			rot_accel.z  		-= g.motor_kv  * motor_output[5] * .08;		// CW 6

			rot_accel.z  		+= g.motor_kv  * motor_output[1] * .08;		// CCW 2
			rot_accel.z  		+= g.motor_kv  * motor_output[3] * .08;		// CCW 4
			rot_accel.z  		+= g.motor_kv  * motor_output[4] * .08;		// CCW 5


			rot_accel.x 		/= g.moment;
			rot_accel.y 		/= g.moment;
			rot_accel.z 		/= g.moment;

			// fake a bad frame
			//rot_accel.z 		+= g.yaw_bias_BI.getNumber();//g.00000;
			rot_accel.x 		+= g.roll_bias_BI.getNumber();// 25000;
			rot_accel.y 		+= g.pitch_bias_BI.getNumber(); //35000;
			trace(rot_accel.x)


    		//# rotational air resistance

			// Gyro is the rotation speed in deg/s
			// update rotational rates in body frame
			ahrs.gyro.x	+= rot_accel.x * dt;
			ahrs.gyro.y	+= rot_accel.y * dt;
			ahrs.gyro.z	+= rot_accel.z * dt;

			//ahrs.gyro.z	+= 200;
			ahrs.gyro.z	*= .995;// some drag

			// move earth frame to body frame
			var tmp:Vector3D = ahrs.dcm.transformVector(ahrs.gyro);

			// update attitude:
			ahrs.dcm.appendRotation((tmp.x/100) * dt, 	Vector3D.X_AXIS);	// ROLL
			ahrs.dcm.appendRotation((tmp.y/100) * dt, 	Vector3D.Y_AXIS); 	// PITCH
			ahrs.dcm.appendRotation((tmp.z/100) * dt, 	Vector3D.Z_AXIS);	// YAW

			// ------------------------------------
			// calc thrust
			// ------------------------------------

			//get_motor_output returns 0 : 1000
			_thrust += motor_output[0] * thrust_scale;
			_thrust += motor_output[1] * thrust_scale;
			_thrust += motor_output[2] * thrust_scale;
			_thrust += motor_output[3] * thrust_scale;
			_thrust += motor_output[4] * thrust_scale;
			_thrust += motor_output[5] * thrust_scale;
			trace(_thrust);

			var accel_body:Vector3D 	= new Vector3D(edf, 0, (_thrust * -1) / g.mass);

			//var accel_body:Vector3D 	= new Vector3D(0, 0, 0);
			var accel_earth:Vector3D	= ahrs.dcm.transformVector(accel_body);
			angle3D						= ahrs.dcm.transformVector(angle3D);

			//trace(ahrs.gyro.y, accel_earth.x);

			//trace(ahrs.gyro.x, ahrs.gyro.y, ahrs.gyro.z);

			// ------------------------------------
			// calc copter velocity
			// ------------------------------------
			// calc Drag
			drag.x = .5 * g.airDensity * airspeed.x * airspeed.x * g.dragCE * g.crossSection;
			drag.y = .5 * g.airDensity * airspeed.y * airspeed.y * g.dragCE * g.crossSection;
			drag.z = .5 * g.airDensity * airspeed.z * airspeed.z * g.dragCE * g.crossSection;

			///*
			// this calulation includes wind
			if(airspeed.x >= 0)
				accel_earth.x 	-= drag.x;
			else
				accel_earth.x 	+= drag.x;

			// Add in Drag
			if(airspeed.y >= 0)
				accel_earth.y 	-= drag.y;
			else
				accel_earth.y 	+= drag.y;

			if(airspeed.z <= 0)
				accel_earth.z 	-= drag.z;
			else
				accel_earth.z 	+= drag.z;
			//*/

			// hacked vert disturbance
			accel_earth.z	+= _jump_z * dt;
			_jump_z 		*= .999;


			// Add in Gravity
			accel_earth.z += gravity;

			if(accel_earth.z < 0)
				accel_earth.z *=.9;


			if(position.z <=.11 && accel_earth.z > 0){
				accel_earth.z = 0;
			}

			velocity.x 		+= (accel_earth.x * dt); // + : Forward (North)
			velocity.y  	+= (accel_earth.y * dt); // + : Right (East)
			velocity.z  	-= (accel_earth.z * dt); // + : Up


			//trace(Math.floor(velocity.x),Math.floor(velocity.y),Math.floor(velocity.z));

			// ------------------------------------
			// calc inertia
			// ------------------------------------

			// work out acceleration as seen by the accelerometers. It sees the kinematic
			// acceleration (ie. real movement), plus gravity
			var dcm_t:Matrix3D			= ahrs.dcm.clone();
			dcm_t.transpose();
			var t:Number = accel_earth.z
			accel_earth.z -= gravity;
			ahrs.accel = dcm_t.transformVector(accel_earth);

			ahrs.accel.scaleBy(.01);

			//ahrs.accel	= accel_earth.clone();
			ahrs.accel.x	*= g.accel_bias_x;
			ahrs.accel.y	*= g.accel_bias_y;
			ahrs.accel.z	*= g.accel_bias_z;



			// ------------------------------------
			// calc Position
			// ------------------------------------
			position.y 		+= velocity.x * dt;
			position.x 		+= velocity.y * dt;
			position.z  	+= velocity.z * dt;
			position.z 		= Math.min(position.z, 4000)

			// XXX Force us to 3m above ground
			//position.z = 300;

			airspeed.x  	= (velocity.x - wind.x);
			airspeed.y  	= (velocity.y - wind.y);
			airspeed.z  	= velocity.z;

			// Altitude
			// --------
			if(position.z <=.1){
				position.z 	= .1;
				velocity.x 	= 0;
				velocity.y 	= 0;
				velocity.z 	= 0;
				//ahrs.init();
			}


			// get omega - the simulated Gyro output
			ahrs.omega.x 		= radiansx100(ahrs.gyro.x);
			ahrs.omega.y 		= radiansx100(ahrs.gyro.y);
			ahrs.omega.z 		= radiansx100(ahrs.gyro.z);

			// get the Eulers output
			v3 = ahrs.dcm.decompose();
			ahrs.roll_sensor 	=  Math.floor(degrees(v3[1].x) * 100);
			ahrs.pitch_sensor 	=  Math.floor(degrees(v3[1].y) * 100);
			ahrs.yaw_sensor 	=  Math.floor(degrees(v3[1].z) * 100);

			// store the position for the GPS object
			loc.lng = position.x;
			loc.lat = position.y;
			loc.alt = position.z;
		}

		public function constrain(val:Number, min:Number, max:Number){
			val = Math.max(val, min);
			val = Math.min(val, max);
			return val;
		}

		public function wrap_180(error:int):Number
		{
			if (error > 18000)	error -= 36000;
			if (error < -18000)	error += 36000;
			return error;
		}

		public function wrap_360(error:int):int
		{
			if (error > 36000)	error -= 36000;
			if (error < 0)		error += 36000;
			return error;
		}

		public function radiansx100(n:Number):Number
		{
			return 0.000174532925 * n;
		}

		public function degreesx100(r:Number):Number
		{
			return r * 5729.57795;
		}
		public function degrees(r:Number):Number
		{
			return r * 57.2957795;
		}
		public function radians(n:Number):Number
		{
			return 0.0174532925 * n;
		}

	}
}
