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

	public class Copter extends MovieClip
	{
		public var ahrs						:AHRS;
		public var loc						:Location;
		public var g						:Parameters;
		public var apm_rc					:APM_RC;

		public var speed					:int = 0;
		public var gravity					:Number = 981;
		public var thrust_scale				:Number = 0.4;
		//public var friction					:Number = .0010; // affects aplitude of oscillations
		public var mass						:Number = 1;
		public var ground_speed				:Number = 0;
		public var roll_target				:Number	= 0;
		public var throttle					:Number	= 500;
		public var altitude_rate			:Number = 9;
		public var omega_x					:Number = 0;

		public var drag						:Vector3D;		//
		public var airspeed					:Vector3D;		//
		public var accel					:Vector3D;		//
		public var position					:Vector3D;		//
		public var velocity					:Vector3D;
		public var wind						:Vector3D;			//
		public var rot_accel				:Vector3D;			//
		public var angle_boost				:Number;
		public var windGenerator			:Wind;			//


		public function Copter():void
		{
			loc = new Location();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);

			drag 		= new Vector3D(0,0,0);
			airspeed 	= new Vector3D(0,0,0);
			accel 		= new Vector3D(0,0,0);
			wind 		= new Vector3D(0,0,0);
			position 	= new Vector3D(0,0,0);
			velocity 	= new Vector3D(0,0,0);
			rot_accel	= new Vector3D(0,0,0);

			windGenerator = new Wind();
			setThrottleCruise(throttle);
	    }

	    public function addedToStage(even:Event) : void
		{
			g = Parameters.getInstance();
		}

		public function setThrottleCruise(c:Number):void
		{
			// c = 0 : 1000
			//thrust_scale = gravity / c;
			thrust_scale = (mass * gravity) / (2 * c);
			trace("thrust_scale ",thrust_scale, c);
			// thrust_scale  0.981 500
		}

		public function update(dt:Number):void
		{
			var thrust	:Number = 0;
			var rot_accel:Vector3D	= new Vector3D(0,0,0);

			wind.x = windGenerator.read();

			// calc Drag
			drag.x = .5 * g.airDensity * (airspeed.x * airspeed.x) * g.dragCE * g.crossSection;
			drag.z = .5 * g.airDensity * (airspeed.z * airspeed.z) * g.dragCE * g.crossSection;

			// radians/s/s
			/*
			rot_accel.x  -= g.motor_kv * .33 * apm_rc.get_motor_output(0);
			rot_accel.x  += g.motor_kv * .33 * apm_rc.get_motor_output(1);

			ahrs.omega.x += rot_accel.x * dt;
			ahrs.addToRoll(ahrs.omega.x * dt);
			*/

			rot_accel.x  -= g.motor_kv * .33 * apm_rc.get_motor_output(0);
			rot_accel.x  += g.motor_kv * .33 * apm_rc.get_motor_output(1);

			//trace(rot_accel.x);

			ahrs.roll_speed.x	+= rot_accel.x * dt;
			ahrs.roll_sensor	+= ahrs.roll_speed.x * dt;
			ahrs.roll_sensor	= wrap_180(ahrs.roll_sensor);

			ahrs.omega.x = radiansx100(ahrs.roll_speed.x);

			// calc thrust
			//get_motor_output returns 0 : 1000
			thrust += apm_rc.get_motor_output(0) * thrust_scale;
			thrust += apm_rc.get_motor_output(1) * thrust_scale;

			//rotaional drag
			//rot_accel.x -= ahrs.omega.x;

			accel.x 	= Math.sin(radiansx100(ahrs.roll_sensor)) * thrust;
			accel.z 	= Math.cos(radiansx100(ahrs.roll_sensor)) * thrust;
			//trace(thrust, accel.z, gravity);
			accel.z 	-= gravity;

			if(airspeed.x >= 0)
				accel.x 	-= drag.x;
			else
				accel.x 	+= drag.x;

			if(airspeed.z >= 0)
				accel.z 	-= drag.z;
			else
				accel.z 	+= drag.z;

			//accel.z  = 2;
			//trace("accel.z ",accel.z);
			//trace(accel.x);

			velocity.x 	+= accel.x * dt;
			velocity.z  += accel.z * dt;

			position.x 	+= velocity.x * dt;
			position.z  += velocity.z * dt;
			position.z 	= Math.min(position.z, 4000)

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
