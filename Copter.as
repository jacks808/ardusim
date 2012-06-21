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

	public class Copter extends MovieClip
	{
		public var ahrs						:AHRS;
		public var loc						:Location;
		public var g						:Parameters;
		public var apm_rc					:APM_RC;
		public var motor_filter_1			:AverageFilter;
		public var motor_filter_0			:AverageFilter;
		public var drag						:Vector3D;		//
		public var airspeed					:Vector3D;		//
		public var thrust					:Vector3D;		//
		public var position					:Vector3D;		//
		public var velocity					:Vector3D;
		public var velocity_old				:Vector3D;
		public var wind						:Vector3D;			//
		public var rot_thrust				:Vector3D;			//
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
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
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
			wind 			= new Vector3D(0,0,0);
			position 		= new Vector3D(0,0,0);
			velocity 		= new Vector3D(0,0,0);
			rot_thrust		= new Vector3D(0,0,0);
			velocity_old 	= new Vector3D(0,0,0);
			setThrottleCruise(throttle);
			ground_speed 	= 0;

		}

		public function setThrottleCruise(c:Number):void
		{
			// c = 0 : 1000
			//thrust_scale = gravity / c;
			thrust_scale = (g.mass * gravity) / (2 * c);
			//trace("thrust_scale ",thrust_scale, c);
			// thrust_scale  0.981 500

			motor_filter_0	= new AverageFilter(g.esc_delay);
			motor_filter_1	= new AverageFilter(g.esc_delay);

			motor_filter_0.force_sample(c);
			motor_filter_1.force_sample(c);
		}

		public function jump():void
		{
			_jump_z = 300;

		}

		public function update(dt:Number):void
		{
			var _thrust	:Number = 0;
			var rot_thrust:Vector3D	= new Vector3D(0,0,0);

			wind.x = windGenerator.read();

			// calc Drag
			drag.x = .5 * g.airDensity * (airspeed.x * airspeed.x) * g.dragCE * g.crossSection;
			drag.z = .5 * g.airDensity * (airspeed.z * airspeed.z) * g.dragCE * g.crossSection;

			// ESC's moving average filter
			var motor_output_0:Number = motor_filter_0.apply(apm_rc.get_motor_output(0));
			var motor_output_1:Number = motor_filter_1.apply(apm_rc.get_motor_output(1));


			rot_thrust.x 		-= g.motor_kv  * motor_output_0;
			rot_thrust.x  		+= g.motor_kv  * motor_output_1;
			//rot_thrust.x		+= 57100 ;
			rot_thrust.x 		/= g.moment;

			ahrs.roll_speed.x	+= rot_thrust.x * dt;
			ahrs.roll_sensor	+= ahrs.roll_speed.x * dt;
			ahrs.roll_sensor	= wrap_180(ahrs.roll_sensor);
			ahrs.omega.x 		= radiansx100(ahrs.roll_speed.x);

			//trace(ahrs.roll_speed.x);

			// calc thrust
			//get_motor_output returns 0 : 1000
			_thrust += motor_output_0 * thrust_scale;
			_thrust += motor_output_1 * thrust_scale;

			//rotaional drag
			//rot_thrust.x -= ahrs.omega.x;

			thrust.x 	= Math.sin(radiansx100(ahrs.roll_sensor)) * _thrust;
			thrust.z 	= Math.cos(radiansx100(ahrs.roll_sensor)) * _thrust;
			var thrust_fix = thrust.z * .1;

			thrust.z -= thrust_fix;
			//thrust.x += thrust_fix /2;

			//thrust.x *= 2.4;

			// Add in Drag
			if(airspeed.x >= 0)
				velocity.x 	-= drag.x * dt;
			else
				velocity.x 	+= drag.x * dt;

			if(airspeed.z >= 0)
				velocity.z 	-= drag.z * dt;
			else
				velocity.z 	+= drag.z * dt;

			velocity.x 		+= (thrust.x * dt) / g.mass;
			velocity.z  	+= (thrust.z * dt) / g.mass;
			velocity.z 		-= gravity * dt;


			velocity.z		+= _jump_z * dt;

			_jump_z 		*= .95;

			// add some lift from airspeed
			//velocity.z		+= airspeed.x * dt * .1;

			ahrs.accel.x 	= (velocity.x - velocity_old.x) / (dt * 100);
			ahrs.accel.z 	= -(velocity.z - velocity_old.z) / (dt * 100);

			ahrs.accel.x	+= g.accel_bias_x;
			ahrs.accel.z	+= g.accel_bias_z;

			//trace(velocity.z, (velocity.z - velocity_old.z) * 100, ahrs.accel.z* 100);

			velocity_old.x 	= velocity.x;
			velocity_old.z 	= velocity.z;

			position.x 		+= velocity.x * dt;
			position.z  	+= velocity.z * dt;
			position.z 		= Math.min(position.z, 4000)

			airspeed.x  	= (velocity.x - wind.x);
			airspeed.z  	= (velocity.z - wind.z);

			ground_speed 	= Math.abs(velocity.x);

			// Altitude
			// --------
			if(position.z <= 0){
				position.z 	= .1;
				velocity.z 	= 0;
				velocity.x 	= 0;
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

		public function wrap_180(error:Number):Number
		{
			if (error > 18000)	error -= 36000;
			if (error < -18000)	error += 36000;
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
