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
	import com.APM_RC;
	import com.AverageFilter;

	public class Copter extends Object
	{
		public var ahrs						:AHRS;
		public var loc						:Location;
		public var g						:Parameters;
		public var apm_rc					:APM_RC;
		public var motor_filter_0			:AverageFilter;
		public var motor_filter_1			:AverageFilter;
		public var motor_filter_2			:AverageFilter;
		public var motor_filter_3			:AverageFilter;
		public var drag						:Vector3D;		//
		public var airspeed					:Vector3D;		//
		public var thrust					:Vector3D;		//
		public var position					:Vector3D;		//
		public var velocity					:Vector3D;
		public var velocity_old				:Vector3D;
		public var wind						:Point;			//
		public var rot_accel				:Vector3D;			//
		public var angle3D					:Vector3D;			//
		public var windGenerator			:Wind;			//

		public var gravity					:Number 	= 981;
		public var thrust_scale				:Number 	= 0.4;
		public var ground_speed				:Number 	= 0;
		public var throttle					:Number		= 500;
		public var rotation_bias			:Number 	= 1;
		private var _jump_z					:Number 	= 0;

		public function Copter():void
		{
			loc = new Location();
			//addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			windGenerator = new Wind();
			g = Parameters.getInstance();
	    }

	    public function addedToStage(even:Event) : void
		{
			//g = Parameters.getInstance();
		}

	    public function init():void
		{
			drag 			= new Vector3D(0,0,0);
			airspeed 		= new Vector3D(0,0,0);
			thrust 			= new Vector3D(0,0,0);
			wind 			= new Point(0,0);
			position 		= new Vector3D(0,0,0);
			velocity 		= new Vector3D(0,0,0);
			angle3D			= new Vector3D(0,0,1);
			rot_accel		= new Vector3D(0,0,0);
			velocity_old 	= new Vector3D(0,0,0);
			setThrottleCruise(throttle);
			ground_speed 	= 0;
			loc.lat = 0;
			loc.lng = 0;
			loc.alt = 0;
		}

		public function setThrottleCruise(c:Number):void
		{
			// c = 0 : 1000
			//thrust_scale = gravity / c;
			thrust_scale = (g.mass * gravity) / (4 * c); // 4 motors
			//trace("thrust_scale ",thrust_scale, c);
			// thrust_scale  0.981 500

			motor_filter_0	= new AverageFilter(g.esc_delay);
			motor_filter_1	= new AverageFilter(g.esc_delay);
			motor_filter_2	= new AverageFilter(g.esc_delay);
			motor_filter_3	= new AverageFilter(g.esc_delay);


			motor_filter_0.force_sample(c);
			motor_filter_1.force_sample(c);
			motor_filter_2.force_sample(c);
			motor_filter_3.force_sample(c);
		}

		public function jump():void
		{
			_jump_z = 300;

		}

		public function update(dt:Number):void
		{
			var _thrust	:Number = 0;
			rot_accel = new Vector3D(0,0,0);
			angle3D.x = angle3D.y = 0;
			angle3D.z = 1;

			wind = windGenerator.read();

			// calc Drag
			drag.x = .5 * g.airDensity * (airspeed.x * airspeed.x) * g.dragCE * g.crossSection;
			drag.y = .5 * g.airDensity * (airspeed.y * airspeed.y) * g.dragCE * g.crossSection;
			drag.z = .5 * g.airDensity * (airspeed.z * airspeed.z) * g.dragCE * g.crossSection;

			// ESC's moving average filter
			var motor_output:Array = new Array(4);

			motor_output[0] = motor_filter_0.apply(apm_rc.get_motor_output(0));
			motor_output[1] = motor_filter_1.apply(apm_rc.get_motor_output(1));
			motor_output[2] = motor_filter_2.apply(apm_rc.get_motor_output(2));
			motor_output[3] = motor_filter_3.apply(apm_rc.get_motor_output(3));

/*
		2

	0		1

		3

*/

			// setup motor rotations
			rot_accel.x 		-= g.motor_kv  * motor_output[0]; // roll
			rot_accel.x  		+= g.motor_kv  * motor_output[1];
			rot_accel.y  		-= g.motor_kv  * motor_output[3];
			rot_accel.y 		+= g.motor_kv  * motor_output[2];

			rot_accel.z  		+= g.motor_kv  * motor_output[0] * .08;
			rot_accel.z  		+= g.motor_kv  * motor_output[1] * .08;
			rot_accel.z  		-= g.motor_kv  * motor_output[2] * .08;
			rot_accel.z  		-= g.motor_kv  * motor_output[3] * .08;

			rot_accel.x 		/= g.moment;
			rot_accel.y 		/= g.moment;
			rot_accel.z 		/= g.moment;

			ahrs.rotation_speed.x	+= rot_accel.x * dt;
			ahrs.rotation_speed.y	+= rot_accel.y * dt;
			ahrs.rotation_speed.z	+= rot_accel.z * dt;
			ahrs.rotation_speed.z	*= .995;// some drag

			ahrs.roll_sensor	+= ahrs.rotation_speed.x * dt;
			ahrs.pitch_sensor	+= ahrs.rotation_speed.y * dt;
			ahrs.yaw_sensor		+= ahrs.rotation_speed.z * dt;

			ahrs.roll_sensor	= wrap_180(ahrs.roll_sensor);
			ahrs.pitch_sensor	= wrap_180(ahrs.pitch_sensor);
			ahrs.yaw_sensor		= wrap_360(ahrs.yaw_sensor);

			//trace(ahrs.roll_sensor, ahrs.pitch_sensor, ahrs.yaw_sensor);

			ahrs.omega.x 		= radiansx100(ahrs.rotation_speed.x);
			ahrs.omega.y 		= radiansx100(ahrs.rotation_speed.y);
			ahrs.omega.z 		= radiansx100(ahrs.rotation_speed.z);

			//trace(ahrs.rotation_speed.x);

			// calc thrust
			//get_motor_output returns 0 : 1000
			_thrust += motor_output[0] * thrust_scale;
			_thrust += motor_output[1] * thrust_scale;
			_thrust += motor_output[2] * thrust_scale;
			_thrust += motor_output[3] * thrust_scale;

			thrust.z = _thrust; // * .9;
			thrust.x = 0;
			thrust.y = 0;

			var m3d:Matrix3D = new Matrix3D();
			m3d.appendRotation(ahrs.pitch_sensor/100, 	Vector3D.X_AXIS);	// Pitch
			m3d.appendRotation(ahrs.roll_sensor/100, 	Vector3D.Y_AXIS); 	// Roll
			m3d.appendRotation(-ahrs.yaw_sensor/100, 	Vector3D.Z_AXIS);	// Yaw
			thrust 	= m3d.transformVector(thrust);
			angle3D = m3d.transformVector(angle3D);

			//trace(thrust);

			//rotaional drag
			//rot_accel.x -= ahrs.omega.x;

			// Add in Drag
			if(airspeed.x >= 0)
				velocity.x 	-= drag.x * dt;
			else
				velocity.x 	+= drag.x * dt;

			// Add in Drag
			if(airspeed.y >= 0)
				velocity.y 	-= drag.y * dt;
			else
				velocity.y 	+= drag.y * dt;

			if(airspeed.z >= 0)
				velocity.z 	-= drag.z * dt;
			else
				velocity.z 	+= drag.z * dt;

			velocity.x 		+= (thrust.x * dt) / g.mass;
			velocity.y  	+= (thrust.y * dt) / g.mass;
			velocity.z  	+= (thrust.z * dt) / g.mass;
			velocity.z 		-= gravity * dt;

			// hacked vert disturbance
			velocity.z		+= _jump_z * dt;
			_jump_z 		*= .95;

			// add some lift from airspeed
			//velocity.z		+= airspeed.x * dt * .1;

			ahrs.accel.x 	= (velocity.x - velocity_old.x) / (dt * 100);
			ahrs.accel.y 	= (velocity.y - velocity_old.y) / (dt * 100);
			ahrs.accel.z 	= -(velocity.z - velocity_old.z) / (dt * 100);

			ahrs.accel.x	+= g.accel_bias_x;
			//ahrs.accel.y	+= g.accel_bias_y;
			ahrs.accel.z	+= g.accel_bias_z;

			velocity_old	= velocity.clone();

			position.x 		+= velocity.x * dt;
			position.y 		+= velocity.y * dt;
			position.z  	+= velocity.z * dt;
			position.z 		= Math.min(position.z, 4000)

			airspeed.x  	= (velocity.x - wind.x);
			airspeed.y  	= (velocity.y - wind.y);
			airspeed.z  	= velocity.z;

			ground_speed 	= Math.abs(velocity.x);// convert to 3d calc

			// Altitude
			// --------
			if(position.z <= 0){
				position.z 	= .1;
				velocity.x 	= 0;
				velocity.y 	= 0;
				velocity.z 	= 0;
				ahrs.init();
			}

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
