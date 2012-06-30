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
		public var sim_iterations			:int 		= 99999;
		public var sim_speed				:int 		= 1;

		public var windSpeedMin				:Number 	= 150;
		public var windSpeedMax				:Number 	= 200;
		public var windPeriod				:Number 	= 30000;
		public var windDir					:Number 	= 45;

		public var airDensity				:Number 	= 1.184;
		//public var crossSection				:Number 	= 0.015;
		public var crossSection				:Number 	= 0.005;
		public var dragCE					:Number 	= 0.20;
		public var speed_filter_size		:Number 	= 2;
		public var motor_kv					:Number 	= 1000;
		public var moment					:Number 	= 3;
		public var mass						:Number 	= 500;
		public var esc_delay				:int 		= 12;
		public var airspeed_fix				:Number 	= 0.0054;


		// -----------------------------------------
		// SIM
		// -----------------------------------------
		public var motor_kv_BI				:BasicInput;
		public var wind_high_BI				:BasicInput;
		public var moment_BI				:BasicInput;
		public var mass_BI					:BasicInput;
		public var esc_delay_BI				:BasicInput;
		public var drag_BI					:BasicInput;
		public var crossSection_BI			:BasicInput;
		public var airDensity_BI			:BasicInput;
		public var speed_filter_BI			:BasicInput;

		// -----------------------------------------
		// Environment
		// -----------------------------------------
		public var start_angle_BI			:BasicInput;
		public var start_climb_rate_BI		:BasicInput;
		public var start_rotation_BI		:BasicInput;
		public var start_speed_BI			:BasicInput;
		public var start_position_BI		:BasicInput;
		public var start_height_BI			:BasicInput;
		public var target_distance_BI		:BasicInput;
		public var target_altitude_BI		:BasicInput;
		public var wind_low_BI				:BasicInput;
		public var wind_period_BI			:BasicInput;

		public var wind_checkbox			:QuickCheckBox;
		public var fastPlot_checkbox		:QuickCheckBox;
		public var axis_enabled_checkbox	:QuickCheckBox;
		public var sonar_checkbox			:QuickCheckBox;
		public var rtl_land_checkbox		:QuickCheckBox;
		public var lead_filter_checkbox		:QuickCheckBox;
		public var simple_checkbox			:QuickCheckBox;

		public var test_checkbox			:QuickCheckBox;

		public var NTUN_checkbox			:QuickCheckBox;
		public var CTUN_checkbox			:QuickCheckBox;

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


		public var test						:Boolean = false;

		// -----------------------------------------
		// Sensors
		// -----------------------------------------
		public var sonar_enabled			:Boolean = false;

		// ---------------------------------------------
		// LEDS
		// ---------------------------------------------
		public var copter_leds_mode			:int = 9;

		// ---------------------------------------------
		// Acro
		// ---------------------------------------------
		public var axis_enabled				:Boolean = false;


		// -----------------------------------------
		// Stabilize
		// -----------------------------------------
		public var pi_stabilize_roll		:PID
		public var pi_stabilize_pitch		:PID
		public var pi_stabilize_yaw			:PID

		public var pid_rate_roll			:PID
		public var pid_rate_pitch			:PID
		public var pid_rate_yaw				:PID

		private var stabilize_p				:Number = 4.5;
		private var stabilize_i				:Number = 0.1;
		private var stabilize_imax			:Number = 4000;

		private var rate_p					:Number = 0.17; // .14
		private var rate_i					:Number = 0.0;
		private var rate_d					:Number = 0.004;  // .002
		private var rate_imax				:Number = 500;
		private var stab_d					:Number = 0.0;


		private var stabilize_yaw_p			:Number = 7.0;
		private var stabilize_yaw_i			:Number = .01;
		private var stabilize_yaw_imax		:Number = 800;

		private var rate_yaw_p				:Number = 0.13; // .14
		private var rate_yaw_i				:Number = 0.0;
		private var rate_yaw_d				:Number = 0.004;  // .002
		private var rate_yaw_imax			:Number = 5000;

		public var super_simple				:Boolean = false;

		// -----------------------------------------
		// Altitude hold
		// -----------------------------------------
		public var pi_alt_hold				:PID
		public var pid_throttle				:PID

		/*
		// inertia gains
		private var alt_hold_p				:Number = 0.5;
		private var alt_hold_i				:Number = 0		// 0.007;
		private var alt_hold_imax			:Number = 300;
		private var throttle_rate_p			:Number = 3.0 	//0.25;
		private var throttle_rate_i			:Number = 0.5;
		private var throttle_rate_d			:Number = 0.0;
		private var throttle_rate_imax		:Number = 300;
		*/

		//reg gains
		private var alt_hold_p				:Number = 0.8;
		private var alt_hold_i				:Number = 0.007
		private var alt_hold_imax			:Number = 300;
		private var throttle_rate_p			:Number = .35
		private var throttle_rate_i			:Number = 0.0;
		private var throttle_rate_d			:Number = 0.0;
		private var throttle_rate_imax		:Number = 300;

		// -----------------------------------------
		// Inertial control
		// -----------------------------------------
		public var speed_correction_x		:Number = 0.020;
		public var speed_correction_z		:Number = 0.0350;
		public var loiter_offset_correction	:Number = 0.000001; //0.000003
		public var loiter_vel_correction	:Number = 0.03;.007
		public var accel_bias_x				:Number = .2;

		public var alt_offset_correction	:Number = 0.000003;
		public var alt_vel_correction		:Number = 0.006;
		public var accel_bias_z				:Number = .2;

		// -----------------------------------------
		// Loiter
		// -----------------------------------------
		public var pi_loiter_lon			:PID
		public var pi_loiter_lat			:PID
		public var pid_loiter_rate_lon		:PID
		public var pid_loiter_rate_lat		:PID

		/*
		// inertia gains
		private var loiter_p				:Number = 0.5; // 0
		private var loiter_rate_p			:Number = 12; // 1.0
		private var loiter_rate_i			:Number = 1.1; // .05
		private var loiter_rate_d			:Number = 0.0; // 3.8
		private var loiter_rate_imax		:Number = 3000; // .05
		*/

		// reg gains
		private var loiter_p				:Number = 0.2; // 0
		private var loiter_rate_p			:Number = 2.4; // 1.0
		private var loiter_rate_i			:Number = 0.08; // .05
		private var loiter_rate_d			:Number = 0.0; // 3.8
		private var loiter_rate_imax		:Number = 3000; // .05


		// -----------------------------------------
		// NAV, RTL
		// -----------------------------------------
		public var pid_nav_lon				:PID;
		public var pid_nav_lat				:PID;
		private var nav_p					:Number = 2.4;
		private var nav_i					:Number = 0.17;
		private var nav_d					:Number = 0.00;
		private var nav_imax				:Number = 3000;
		public var rtl_approach_alt			:int = 100;
		public var RTL_altitude				:int = 1000; // ALT_HOLD_HOME  height to return to Home, 0 = Maintain current altitude

		// Waypoints
		//
		public var command_total			:int = 0;
		public var command_index			:int = 0;
		public var command_nav_index		:int = 0;
		public var waypoint_radius			:int = 100;
		public var loiter_radius			:int = 10;
		public var waypoint_speed_max		:Number = 600;
		public var crosstrack_gain			:Number = .2;
		public var auto_land_timeout		:Number = 5000;// milliseconds

		// Throttle
		//
		public var throttle_min				:int 		= 130;
		public var throttle_max				:int 		= 1000;
		public var throttle_fs_enabled		:Boolean 	= true;
		public var throttle_fs_action		:int 		= 2;
		public var throttle_fs_value		:int 		= 975;
		public const THROTTLE_CRUISE		:int		= 551;

		public var throttle_cruise			:Number 	= 551;
		public var throttle_cruise_e		:Number 	= 0;


		// Flight modes
		//
		public var flight_mode1				:int 		= 0; // STABILIZE
		public var flight_mode2				:int 		= 0;
		public var flight_mode3				:int 		= 0;
		public var flight_mode4				:int 		= 0;
		public var flight_mode5				:int 		= 0;
		public var flight_mode6				:int 		= 0;
		public var simple_modes				:int 		= 0;

		// Misc
		//
		//public var ch7_option				:int		= 0; // CH7_DO_NOTHING 0
		//public var ch7_option				:int		= 1; // CH7_SET_HOVER 1
		//public var ch7_option				:int		= 2; // CH7_FLIP 2
		//public var ch7_option				:int		= 3; // CH7_SIMPLE_MODE 3
		public var ch7_option				:int		= 4; // CH7_RTL 4
		//public var ch7_option				:int		= 5; // CH7_AUTO_TRIM 5
		//public var ch7_option				:int		= 6; // CH7_ADC_FILTER 6
		//public var ch7_option				:int		= 7; // CH7_SAVE_WP 7

		public var auto_slew_rate			:Number 	= 60;

		// RC channels
		public var rc_1						:RC_Channel;
		public var rc_2						:RC_Channel;
		public var rc_3						:RC_Channel;
		public var rc_4						:RC_Channel;
		public var rc_5						:RC_Channel;
		public var rc_6						:RC_Channel;
		public var rc_7						:RC_Channel;
		public var rc_8						:RC_Channel;

		public var rc_camera_pitch			:RC_Channel;
		public var rc_camera_roll			:RC_Channel;

		public var camera_pitch_gain		:Number = 1.0;
		public var camera_roll_gain			:Number = 1.0;
		public var stabilize_d_schedule		:Number = .5;
		public var stabilize_d				:Number = 0;

		public var acro_p					:Number = 9.5; // 4.5 default
		public var axis_lock_p				:Number = .02;


		public var toy_yaw_rate				:int = 1; // 1 = fast, 2 = med, 3 = slow


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
			pi_loiter_lat 			= new PID(loiter_p, 0, 0, 3000);				// Raise P to decrease frequency
			pid_loiter_rate_lon 	= new PID(loiter_rate_p, loiter_rate_i , loiter_rate_d, loiter_rate_imax);
			pid_loiter_rate_lat 	= new PID(loiter_rate_p, loiter_rate_i , loiter_rate_d, loiter_rate_imax);

			// Alt Hold
			pi_alt_hold 			= new PID(alt_hold_p, alt_hold_i, 0, 300);
			pid_throttle 			= new PID(throttle_rate_p, throttle_rate_i, throttle_rate_d, 300);

			// Stabilie
			pi_stabilize_roll 		= new PID(stabilize_p, 		stabilize_i, 0, 	stabilize_imax);
			pi_stabilize_pitch 		= new PID(stabilize_p, 		stabilize_i, 0, 	stabilize_imax);
			pi_stabilize_yaw 		= new PID(stabilize_yaw_p, 	stabilize_yaw_i, 0, stabilize_yaw_imax);

			pid_rate_roll 			= new PID(rate_p, rate_i, rate_d, rate_imax);
			pid_rate_pitch 			= new PID(rate_p, rate_i, rate_d, rate_imax);
			pid_rate_yaw 			= new PID(rate_yaw_p, rate_yaw_i, rate_yaw_d, rate_yaw_imax);

			// nav
			pid_nav_lon 			= new PID(nav_p, nav_i , nav_d, nav_imax);
			pid_nav_lat 			= new PID(nav_p, nav_i , nav_d, nav_imax);

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
			wind_checkbox.setLabel("Enable Wind");
			fastPlot_checkbox.setLabel("Fast plot");

			baro_noise_checkbox.setLabel("Baro Noise");
			axis_enabled_checkbox.setLabel("Axis Lock");
			//rtl_land_checkbox.setLabel("RTL Land Enabled");
			sonar_checkbox.setLabel("Sonar Enabled");

			NTUN_checkbox.setLabel("Log NTUN");
			CTUN_checkbox.setLabel("Log CTUN");
			GPS_checkbox.setLabel("Log GPS");
			ATT_checkbox.setLabel("Log ATT");
			test_checkbox.setLabel("A/B Test Option");
			lead_filter_checkbox.setLabel("GPS Lead Filter");
			inertia_checkbox.setLabel("Inertial Control");
			simple_checkbox.setLabel("Simple Mode");
			initGains();
		}

		private function initGains():void
		{
			sim_speed_BI.setNumber(sim_speed);
			lead_filter_checkbox.setSelected(true);
			toy_yaw_rate_BI.setNumber(toy_yaw_rate);

			//auto_slew_rate_BI.setNumber(auto_slew_rate);
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
			axis_enabled_checkbox.setSelected(axis_enabled);
			sonar_checkbox.setSelected(sonar_enabled);
			//rtl_land_checkbox.setSelected(rtl_land_enabled);

			RTL_altitude_BI.setNumber(RTL_altitude);
			rtl_approach_alt_BI.setNumber(rtl_approach_alt);

			// for testing alternatives
			test_checkbox.setSelected(test);

			speed_correction_x_BI.setNumber(speed_correction_x);
			loiter_offset_correction_BI.setNumber(loiter_offset_correction);
			loiter_vel_correction_BI.setNumber(loiter_vel_correction);
			accel_bias_x_BI.setNumber(accel_bias_x);

			speed_correction_z_BI.setNumber(speed_correction_z);
			alt_offset_correction_BI.setNumber(alt_offset_correction);
			alt_vel_correction_BI.setNumber(alt_vel_correction);
			accel_bias_z_BI.setNumber(accel_bias_z);

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
			crosstrack_gain_BI.setNumber(crosstrack_gain);

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
			windDir_BI.setNumber(windDir);
			start_speed_BI.setNumber(0);
			start_rotation_BI.setNumber(0);
			start_climb_rate_BI.setNumber(0);
			start_angle_BI.setNumber(0);

			motor_kv_BI.setNumber(motor_kv);
			moment_BI.setNumber(moment);
			mass_BI.setNumber(mass);
			esc_delay_BI.setNumber(esc_delay);
			airspeed_fix_BI.setNumber(airspeed_fix);
		}

		public function updateGains():void
		{
			sim_speed					= sim_speed_BI.getNumber();

			//auto_slew_rate				= auto_slew_rate_BI.getNumber();
			toy_yaw_rate				= toy_yaw_rate_BI.getNumber();

			// stabilize
			pi_stabilize_roll._kp		= stab_roll_P_BI.getNumber();
			pi_stabilize_roll._ki		= stab_roll_I_BI.getNumber();
			pi_stabilize_roll._imax		= stab_roll_Imax_BI.getNumber();

			pi_stabilize_pitch._kp		= stab_roll_P_BI.getNumber();
			pi_stabilize_pitch._ki		= stab_roll_I_BI.getNumber();
			pi_stabilize_pitch._imax	= stab_roll_Imax_BI.getNumber();

			pid_rate_roll._kp			= stab_rate_P_BI.getNumber();
			pid_rate_roll._ki			= stab_rate_I_BI.getNumber();
			pid_rate_roll._imax			= stab_rate_Imax_BI.getNumber();
			pid_rate_roll._kd			= stab_rate_D_BI.getNumber();

			pid_rate_pitch._kp			= stab_rate_P_BI.getNumber();
			pid_rate_pitch._ki			= stab_rate_I_BI.getNumber();
			pid_rate_pitch._imax		= stab_rate_Imax_BI.getNumber();
			pid_rate_pitch._kd			= stab_rate_D_BI.getNumber();

			stabilize_d_schedule 		= stabilize_d_schedule_BI.getNumber();
			stabilize_d 				= stabilize_d_BI.getNumber();

			// acro
			acro_p						= acro_P_BI.getNumber();
			axis_enabled				= axis_enabled_checkbox.getSelected();
			sonar_enabled				= sonar_checkbox.getSelected();
			//rtl_land_enabled			= rtl_land_checkbox.getSelected();

			RTL_altitude				= RTL_altitude_BI.getNumber();
			rtl_approach_alt			= rtl_approach_alt_BI.getNumber();


			// for testing alternatives
			test						= test_checkbox.getSelected();

			speed_correction_x			= speed_correction_x_BI.getNumber();
			loiter_offset_correction	= loiter_offset_correction_BI.getNumber();
			loiter_vel_correction		= loiter_vel_correction_BI.getNumber();
			accel_bias_x				= accel_bias_x_BI.getNumber();

			speed_correction_z			= speed_correction_z_BI.getNumber();
			alt_offset_correction		= alt_offset_correction_BI.getNumber();
			alt_vel_correction			= alt_vel_correction_BI.getNumber();
			accel_bias_z				= accel_bias_z_BI.getNumber();


			// loiter
			pi_loiter_lon._kp			= loiter_hold_P_BI.getNumber();
			pid_loiter_rate_lon._kp 	= loiter_rate_P_BI.getNumber();
			pid_loiter_rate_lon._ki 	= loiter_rate_I_BI.getNumber();
			pid_loiter_rate_lon._imax 	= loiter_rate_Imax_BI.getNumber();
			pid_loiter_rate_lon._kd 	= loiter_rate_D_BI.getNumber();

			pi_loiter_lat._kp			= loiter_hold_P_BI.getNumber();
			pid_loiter_rate_lat._kp 	= loiter_rate_P_BI.getNumber();
			pid_loiter_rate_lat._ki 	= loiter_rate_I_BI.getNumber();
			pid_loiter_rate_lat._imax 	= loiter_rate_Imax_BI.getNumber();
			pid_loiter_rate_lat._kd 	= loiter_rate_D_BI.getNumber();

			// nav
			waypoint_speed_max			= waypoint_speed_max_BI.getNumber();
			pid_nav_lon._kp 			= nav_P_BI.getNumber();
			pid_nav_lon._ki 			= nav_I_BI.getNumber();
			pid_nav_lon._imax 			= nav_Imax_BI.getNumber();
			pid_nav_lon._kd 			= nav_D_BI.getNumber();

			pid_nav_lat._kp 			= nav_P_BI.getNumber();
			pid_nav_lat._ki 			= nav_I_BI.getNumber();
			pid_nav_lat._imax 			= nav_Imax_BI.getNumber();
			pid_nav_lat._kd 			= nav_D_BI.getNumber();
			crosstrack_gain				= crosstrack_gain_BI.getNumber();

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
			moment						= moment_BI.getNumber();
			mass						= mass_BI.getNumber();
			esc_delay					= esc_delay_BI.getNumber();
			airspeed_fix				= airspeed_fix_BI.getNumber();

			if(moment == 0) moment = 1;
			if(mass == 0) mass = 1;
		}

	}
}
