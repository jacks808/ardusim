package com {
	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.display.Bitmap;
    import flash.display.BitmapData;

	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	import com.Plot;
	import com.PlotView;
	import com.AverageFilter;
	import com.QuickMenu;
	import com.QuickMenuItem;
	import com.QuickPopupMenu;
	import com.BasicInput;
	import com.Wind;
	import com.AHRS;
	import com.PID;

	public class Parameters extends MovieClip
	{
		private static var instance			:Parameters = null;
		public var frame					:Rectangle;
		public var originalX				:Number = 0;

		// ---------------------------------------------
		// Sim Details controls
		// ---------------------------------------------
		public var sim_iterations			:int = 5000;
		public var windSpeedMin				:Number = 25;
		public var windSpeedMax				:Number = 100;
		public var windPeriod				:Number = 30000;
		public var airDensity				:Number = 1.184;
		public var crossSection				:Number = 0.0325;  // 3.3° at 1m/s wind , 7° at 1.5m/s wind, 12° at 2m/s wind 22° at 2.5m/s wind
		public var dragCE					:Number = 0.25;
		public var speed_filter_size		:Number = 2;
		public var motor_kv					:Number = 1000;

		public var motor_kv_BI				:BasicInput;
		public var wind_high_BI				:BasicInput;

		// -----------------------------------------
		// SIM
		// -----------------------------------------
		public var drag_BI					:BasicInput;
		public var crossSection_BI			:BasicInput;
		public var airDensity_BI			:BasicInput;
		public var speed_filter_BI			:BasicInput;

		// -----------------------------------------
		// Environment
		// -----------------------------------------
		public var start_angle_BI			:BasicInput;
		public var start_speed_BI			:BasicInput;
		public var start_position_BI		:BasicInput;
		public var start_height_BI			:BasicInput;

		public var target_distance_BI		:BasicInput;
		public var target_altitude_BI		:BasicInput;

		public var wind_low_BI				:BasicInput;
		public var wind_period_BI			:BasicInput;
		public var wind_checkbox			:QuickCheckBox;
		public var gps_checkbox				:QuickCheckBox;	// for Ryan's estimator
		public var fastPlot_checkbox		:QuickCheckBox;	// for Ryan's estimator


		// Logging
		public var NTUN_checkbox				:QuickCheckBox;	// for Ryan's estimator
		public var CTUN_checkbox				:QuickCheckBox;	// for Ryan's estimator
		//public var gps_checkbox				:QuickCheckBox;	// for Ryan's estimator


		// -----------------------------------------
		// Sensors
		// -----------------------------------------
		public var sonar_enabled			:Boolean = false;

		// ---------------------------------------------
		// Throttle
		// ---------------------------------------------
		public var throttle_min				:int = 0
		public var throttle_max				:int = 1000
		public var throttle_fs_enabled		:Boolean = true;
		public var throttle_fs_action		:int = 2
		public var throttle_fs_value		:int = 975
		public var throttle_cruise			:Number = 500;
		public var throttle_cruise_e		:Number = 0;

		// ---------------------------------------------
		// GUI controls
		// ---------------------------------------------

		// stability
		public var stab_roll_P_BI			:BasicInput;
		public var stab_roll_I_BI			:BasicInput;
		public var stab_roll_Imax_BI		:BasicInput;
		public var stab_rate_P_BI			:BasicInput;
		public var stab_rate_I_BI			:BasicInput;
		public var stab_rate_Imax_BI		:BasicInput;
		public var stab_rate_D_BI			:BasicInput;
		public var stabilize_d_BI			:BasicInput;
		public var stabilize_d_schedule_BI	:BasicInput;

		// Acro
		public var acro_P_BI				:BasicInput;

		// loiter
		public var loiter_hold_P_BI			:BasicInput;
		public var loiter_rate_P_BI			:BasicInput;
		public var loiter_rate_I_BI			:BasicInput;
		public var loiter_rate_Imax_BI		:BasicInput;
		public var loiter_rate_D_BI			:BasicInput;

		// nav
		public var waypoint_speed_max_BI	:BasicInput;
		public var nav_P_BI					:BasicInput;
		public var nav_I_BI					:BasicInput;
		public var nav_Imax_BI				:BasicInput;
		public var nav_D_BI					:BasicInput;


		public var alt_hold_P_BI			:BasicInput;
		public var alt_hold_I_BI			:BasicInput;
		public var alt_hold_Imax_BI			:BasicInput;

		// Alt hold
		public var alt_rate_P_BI			:BasicInput;
		public var alt_rate_I_BI			:BasicInput;
		public var alt_rate_Imax_BI			:BasicInput;
		public var alt_rate_D_BI			:BasicInput;
		public var throttle_error_BI		:BasicInput;


		// ---------------------------------------------
		// Radio
		// ---------------------------------------------
		public var rc_1						:RC_Channel;
		public var rc_2						:RC_Channel;
		public var rc_3						:RC_Channel;
		public var rc_4						:RC_Channel;
		public var rc_5						:RC_Channel;
		public var rc_6						:RC_Channel;
		public var rc_7						:RC_Channel;
		public var rc_8						:RC_Channel;


		// ---------------------------------------------
		// Acro
		// ---------------------------------------------
		public var axis_enabled				:Boolean = false;
		public var axis_lock_p				:Number = .02;


		// -----------------------------------------
		// Stabilize
		// -----------------------------------------
		public var pi_stabilize_roll		:PID
		public var pid_rate_roll			:PID
		private var stabilize_p				:Number = 4.5;
		private var stabilize_i				:Number = 0.1;
		private var stabilize_imax			:Number = 4000;

		private var rate_p					:Number = 0.14;
		private var rate_i					:Number = 0.0;
		private var rate_d					:Number = 0.0;
		private var rate_imax				:Number = 500;
		private var stab_d					:Number = 0.0;

		public var stabilize_d_schedule		:Number = .5;
		public var stabilize_d				:Number = .45;

		// -----------------------------------------
		// Acro
		// -----------------------------------------
		public var acro_p					:Number = 9.5; // 4.5 default

		// -----------------------------------------
		// Altitude hold
		// -----------------------------------------
		public var pi_alt_hold				:PID
		public var pid_throttle				:PID
		private var alt_hold_p				:Number = 0.5;
		private var alt_hold_i				:Number = 0.007;
		private var alt_hold_imax			:Number = 300;
		private var throttle_rate_p			:Number = 0.25;
		private var throttle_rate_i			:Number = 0.0;
		private var throttle_rate_d			:Number = 0.02;
		private var throttle_rate_imax		:Number = 300;


		// -----------------------------------------
		// Loiter
		// -----------------------------------------
		public var pi_loiter_lon			:PID
		public var pid_loiter_rate_lon		:PID
		private var loiter_p				:Number = 0.4; // 0
		private var loiter_rate_p			:Number = 3.0; // 1.0
		private var loiter_rate_i			:Number = 0.08; // .05
		private var loiter_rate_d			:Number = 0.45; // 3.8
		private var loiter_rate_imax		:Number = 3000; // .05

		// -----------------------------------------
		// NAV, RTL
		// -----------------------------------------
		public var pid_nav_lon				:PID
		private var nav_p					:Number = 3.0;
		private var nav_i					:Number = 0.20;
		private var nav_d					:Number = 0.00;
		private var nav_imax				:Number = 3000;
		public var rtl_approach_alt			:int = 100;
		public var rtl_land_enabled			:Boolean = false;
		public var auto_slew_rate			:Number = 30;
		public var RTL_altitude				:int = 0; // ALT_HOLD_HOME  height to return to Home, 0 = Maintain current altitude


		public var command_total			:int = 0;
		public var command_index			:int = 0;
		public var command_nav_index		:int = 0;
		public var waypoint_radius			:int = 100;
		public var loiter_radius			:int = 10;
		public var waypoint_speed_max		:Number = 600;
		public var crosstrack_gain			:int = 1;
		public var auto_land_timeout		:Number = 10000;// milliseconds

		public var ch7_option				:int = 7; //CH7_SAVE_WP

		public function Parameters():void
		{
			if (instance == null)
			  instance = this;

			frame 		= new Rectangle(0,0,250,450);

			// radio
			rc_1	= new RC_Channel(); // instantiated onscreen
			rc_2	= new RC_Channel();
			rc_3	= new RC_Channel();	// instantiated onscreen
			rc_4	= new RC_Channel();
			rc_5	= new RC_Channel();
			rc_6	= new RC_Channel();
			rc_7	= new RC_Channel();
			rc_8	= new RC_Channel();


			// Loiter
			pi_loiter_lon 			= new PID(loiter_p, 0, 0, 3000);				// Raise P to decrease frequency
			pid_loiter_rate_lon 	= new PID(loiter_rate_p, loiter_rate_i , loiter_rate_d, loiter_rate_imax);

			// Alt Hold
			pi_alt_hold 			= new PID(alt_hold_p, alt_hold_i, 0, 300);
			pid_throttle 			= new PID(throttle_rate_p, throttle_rate_i, throttle_rate_d, 300);

			// Stabilie
			pi_stabilize_roll 		= new PID(stabilize_p, stabilize_i, 0, 300);
			pid_rate_roll 			= new PID(rate_p, rate_i, rate_d, rate_imax);

			// nav
			pid_nav_lon 			= new PID(nav_p, nav_i , nav_d, nav_imax);

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		//Parameters.getInstance();
		static public function getInstance():Parameters
		{
			//if (instance == null)
			  //instance = new DragManager();
			return instance;
		}

		public function addedToStage(event:Event):void {
			originalX = this.x;
			gps_checkbox.setLabel("GPS Estimator");
			wind_checkbox.setLabel("Enable Wind");
			fastPlot_checkbox.setLabel("Fast plot");

			baro_noise_checkbox.setLabel("Baro Noise");

			initGains();
		}

		private function initGains():void
		{
			// stabilize
			stab_roll_P_BI.setNumber(stabilize_p);
			stab_roll_I_BI.setNumber(stabilize_i);
			stab_roll_Imax_BI.setNumber(stabilize_imax);

			stab_rate_P_BI.setNumber(rate_p);
			stab_rate_I_BI.setNumber(rate_i);
			stab_rate_Imax_BI.setNumber(rate_imax);
			stab_rate_D_BI.setNumber(rate_d);

			stabilize_d_schedule_BI.setNumber(stabilize_d_schedule);
			stabilize_d_BI.setNumber(stabilize_d);

			// Acro P
			acro_P_BI.setNumber(acro_p);

			// loiter
			loiter_hold_P_BI.setNumber(loiter_p);
			loiter_rate_P_BI.setNumber(loiter_rate_p);
			loiter_rate_I_BI.setNumber(loiter_rate_i);
			loiter_rate_Imax_BI.setNumber(loiter_rate_imax);
			loiter_rate_D_BI.setNumber(loiter_rate_d);


			// nav
			waypoint_speed_max_BI.setNumber(waypoint_speed_max);
			nav_P_BI.setNumber(nav_p);
			nav_I_BI.setNumber(nav_i);
			nav_Imax_BI.setNumber(nav_imax);
			nav_D_BI.setNumber(nav_d);

			// alt hold
			alt_hold_P_BI.setNumber(alt_hold_p);
			alt_hold_I_BI.setNumber(alt_hold_i);
			alt_hold_Imax_BI.setNumber(alt_hold_imax);

			alt_rate_P_BI.setNumber(throttle_rate_p);
			alt_rate_I_BI.setNumber(throttle_rate_i);
			alt_rate_Imax_BI.setNumber(throttle_rate_imax);
			alt_rate_D_BI.setNumber(throttle_rate_d);
			throttle_error_BI.setNumber(throttle_cruise_e);


			// SIM
			drag_BI.setNumber(dragCE);
			airDensity_BI.setNumber(airDensity);
			crossSection_BI.setNumber(crossSection);
			speed_filter_BI.setNumber(speed_filter_size);

			// -----------
			start_height_BI.setNumber(300);
			start_position_BI.setNumber(0);
			target_distance_BI.setNumber(0);
			target_altitude_BI.setNumber(300);
			wind_low_BI.setNumber(windSpeedMin);
			wind_high_BI.setNumber(windSpeedMax);
			wind_period_BI.setNumber(windPeriod/1000);
			start_speed_BI.setNumber(0);
			start_angle_BI.setNumber(0);

			motor_kv_BI.setNumber(motor_kv);

		}

		public function updateGains():void
		{
			// stabilize
			pi_stabilize_roll._kp		= stab_roll_P_BI.getNumber();
			pi_stabilize_roll._ki		= stab_roll_I_BI.getNumber();
			pi_stabilize_roll._imax		= stab_roll_Imax_BI.getNumber();

			pid_rate_roll._kp			= stab_rate_P_BI.getNumber();
			pid_rate_roll._ki			= stab_rate_I_BI.getNumber();
			pid_rate_roll._imax			= stab_rate_Imax_BI.getNumber();
			pid_rate_roll._kd			= stab_rate_D_BI.getNumber();

			stabilize_d_schedule 		= stabilize_d_schedule_BI.getNumber();
			stabilize_d 				= stabilize_d_BI.getNumber();

			// acro
			acro_p						= acro_P_BI.getNumber();


			// loiter
			pi_loiter_lon._kp			= loiter_hold_P_BI.getNumber();
			pid_loiter_rate_lon._kp 	= loiter_rate_P_BI.getNumber();
			pid_loiter_rate_lon._ki 	= loiter_rate_I_BI.getNumber();
			pid_loiter_rate_lon._imax 	= loiter_rate_Imax_BI.getNumber();
			pid_loiter_rate_lon._kd 	= loiter_rate_D_BI.getNumber();

			// nav
			waypoint_speed_max			= waypoint_speed_max_BI.getNumber();
			pid_nav_lon._kp 			= nav_P_BI.getNumber();
			pid_nav_lon._ki 			= nav_I_BI.getNumber();
			pid_nav_lon._imax 			= nav_Imax_BI.getNumber();
			pid_nav_lon._kd 			= nav_D_BI.getNumber();

			// alt hold
			pi_alt_hold._kp 			= alt_hold_P_BI.getNumber();
			pi_alt_hold._ki 			= alt_hold_I_BI.getNumber();
			pi_alt_hold._imax 			= alt_hold_Imax_BI.getNumber();

			pid_throttle._kp 			= alt_rate_P_BI.getNumber();
			pid_throttle._ki 			= alt_rate_I_BI.getNumber();
			pid_throttle._imax 			= alt_rate_Imax_BI.getNumber();
			pid_throttle._kd 			= alt_rate_D_BI.getNumber();
			throttle_cruise_e 			= throttle_error_BI.getNumber();

			// SIM
			dragCE						= drag_BI.getNumber();
			airDensity					= airDensity_BI.getNumber();
			crossSection				= crossSection_BI.getNumber();
			speed_filter_size			= speed_filter_BI.getNumber();

			motor_kv					= motor_kv_BI.getNumber();
		}



	}
}
