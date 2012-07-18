package com {

	//import caurina.transitions.Tweener;

	import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageDisplayState;

	import flash.display.DisplayObject;
    import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.utils.*;

    import flash.display.StageScaleMode;

	import flash.text.TextField;
	import flash.ui.Keyboard;
	import com.GPS;
	import com.Location;

	import com.Parameters;
	import com.Plot;
	import com.PlotView;
	import com.AverageFilter;
	import com.LeadFilter;
	import com.QuickMenu;
	import com.QuickMenuItem;
	import com.QuickMenuDivider;
	import com.QuickPopupMenu;
	import com.BasicInput;
	import com.Wind;
	import com.AHRS;
	import com.PID;
	import com.Baro;
	import com.Sonar;
	import com.Motors;
	import com.Relay;
	import com.APM_RC;
	import com.User;
	import com.WaypointManager;



	public class Main extends MovieClip
	{
		////////////////////////////////////////////////////////////////////////////////
		// SIM
		////////////////////////////////////////////////////////////////////////////////
		//
		// Global parameters are all contained within the 'g' class.
		//
		public var user								:User;
		public var simIsRunnning					:Boolean = false;
		public var iteration						:int = 0;
		public var copter							:Copter;
		public var ahrs								:AHRS;
		public var relay							:Relay;
		public var apm_rc							:APM_RC;
		public var failsafe							:Boolean = false;
		public var radio_failure					:Boolean = false;
		//public var lng_offset						:Number = -1224646763;
		//public var lat_offset						:Number = 377679601;


		////////////////////////////////////////////////////////////////////////////////
		// Parameters
		////////////////////////////////////////////////////////////////////////////////
		//
		// Global parameters are all contained within the 'g' class.
		//
		public var g								:Parameters;
		public var wp_manager						:WaypointManager;


		////////////////////////////////////////////////////////////////////////////////
		// Sensors
		////////////////////////////////////////////////////////////////////////////////
		//
		// There are three basic options related to flight sensor selection.
		//
		// - Normal flight mode.  Real sensors are used.
		// - HIL Attitude mode.  Most sensors are disabled, as the HIL
		//   protocol supplies attitude information directly.
		// - HIL Sensors mode.  Synthetic sensors are configured that
		//   supply data from the simulation.
		//
		public var g_gps							:GPS;

		public var flight_mode_strings				:Array;
		public var flight_modes						:Array;
		public var radio_switch_position			:int;


		public var x_actual_speed					:Number = 0;
		public var y_actual_speed					:Number = 0;

		public var x_rate_error						:Number = 0;
		public var y_rate_error						:Number = 0;

		public var x_target_speed					:Number = 0;
		public var y_target_speed					:Number = 0;


		////////////////////////////////////////////////////////////////////////////////
		// Radio
		////////////////////////////////////////////////////////////////////////////////
		// This is the state of the flight control system
		// There are multiple states defined such as STABILIZE, ACRO,
		public var control_mode						:int = 2;




		public var new_radio_frame					:Boolean = false;
		public var colors							:Array;
		public var colorIndex						:int = -1;
		public var motors							:Motors;
		public var waypoints						:Array;


		public var ch_1_pwm							:int = 1500;
		public var ch_2_pwm							:int = 1500;
		public var ch_3_pwm							:int = 1500;
		public var ch_4_pwm							:int = 1500;
		public var ch_5_pwm							:int = 1500;
		public var ch_6_pwm							:int = 1500;
		public var ch_7_pwm							:int = 1500;

		public var throttle_integrator				:int = 0;

		public var motor_out						:Array;
		// --------------------------------------
		// Defines
		// --------------------------------------
		public const STABILIZE						:int = 0;
		public const ACRO							:int = 1;
		public const ALT_HOLD						:int = 2;
		public const AUTO							:int = 3;
		public const GUIDED							:int = 4;
		public const LOITER							:int = 5;
		public const RTL							:int = 6;
		public const CIRCLE							:int = 7;
		public const POSITION						:int = 8;
		public const LAND							:int = 9;
		public const OF_LOITER						:int = 10;
		public const TOY							:int = 11;	// THOR Enum for Toy mode


		public const LOITER_MODE					:int = 1;
		public const WP_MODE						:int = 2;
		public const CIRCLE_MODE					:int = 3;
		public const NO_NAV_MODE					:int = 4;
		public const TOY_MODE						:int = 5;	// THOR This mode defines the Virtual WP following mode


		public const YAW_HOLD 						:int = 0;
		public const YAW_ACRO 						:int = 1;
		public const YAW_AUTO 						:int = 2;
		public const YAW_LOOK_AT_HOME 				:int = 3;
		public const YAW_TOY 						:int = 4;	// THOR This is the Yaw mode

		public const ROLL_PITCH_STABLE				:int = 0;
		public const ROLL_PITCH_ACRO				:int = 1;
		public const ROLL_PITCH_AUTO				:int = 2;
		public const ROLL_PITCH_STABLE_OF			:int = 3;
		public const ROLL_PITCH_TOY					:int = 4;	// THOR This is the Roll and Pitch mode

		public const THROTTLE_MANUAL				:int = 0;
		public const THROTTLE_HOLD					:int = 1;
		public const THROTTLE_AUTO					:int = 2;

		public const ASCENDING						:int = 1;
		public const DESCENDING						:int = -1;
		public const REACHED_ALT					:int = 0;
		//public const MINIMUM_THROTTLE				:int = 130;
		//public const MAXIMUM_THROTTLE				:int = 1000;
		public const WAYPOINT_SPEED_MIN				:int = 100;
		public const THROTTLE_ADJUST				:int = 225;

		public const CH_1							:int = 0;
		public const CH_2							:int = 1;
		public const CH_3							:int = 2;
		public const CH_4							:int = 3;
		public const CH_5							:int = 4;
		public const CH_6							:int = 5;
		public const CH_7							:int = 6;
		public const CH_8							:int = 7;

		public const MOT_1							:int = 0;
		public const MOT_2							:int = 1;
		public const MOT_3							:int = 2;
		public const MOT_4							:int = 3;

		public const RADX100						:Number = 0.000174532925;
		public const DEGX100						:Number = 5729.57795;
		public const FS_COUNTER						:int = 3;

		// AP Command enumeration
		public const MAV_CMD_NAV_WAYPOINT			:int = 16;
		public const MAV_CMD_NAV_LOITER_UNLIM		:int = 17;
		public const MAV_CMD_NAV_LOITER_TURNS		:int = 18;
		public const MAV_CMD_NAV_LOITER_TIME		:int = 19;
		public const MAV_CMD_NAV_RETURN_TO_LAUNCH	:int = 20;
		public const MAV_CMD_NAV_LAND				:int = 21;
		public const MAV_CMD_NAV_TAKEOFF			:int = 22;
		public const MAV_CMD_NAV_LAST				:int = 95;

		public const MAV_CMD_CONDITION_DELAY		:int = 112;
		public const MAV_CMD_CONDITION_DISTANCE		:int = 114;
		public const MAV_CMD_CONDITION_CHANGE_ALT	:int = 113;
		public const MAV_CMD_CONDITION_YAW			:int = 115;
		public const MAV_CMD_CONDITION_LAST			:int = 159;

		public const MAV_CMD_DO_JUMP				:int = 177;
		public const MAV_CMD_DO_CHANGE_SPEED		:int = 178;
		public const MAV_CMD_DO_SET_HOME			:int = 179;
		public const MAV_CMD_DO_SET_SERVO			:int = 183;
		public const MAV_CMD_DO_SET_RELAY			:int = 181;
		public const MAV_CMD_DO_REPEAT_SERVO		:int = 184;
		public const MAV_CMD_DO_REPEAT_RELAY		:int = 182;
		public const MAV_CMD_DO_SET_ROI				:int = 201;

		public const MAV_ROI_NONE					:int = 0;
		public const MAV_ROI_WPNEXT					:int = 1;
		public const MAV_ROI_WPINDEX				:int = 2;
		public const MAV_ROI_LOCATION				:int = 3;
		public const MAV_ROI_TARGET					:int = 4;
		public const MAV_ROI_ENUM_END				:int = 5;

		public const CMD_BLANK						:int = 0;
		public const NO_COMMAND						:int = 0;

		// disarm the copter after no throttle
		public const AUTO_DISARMING_DELAY			:int = 20;



		// nav byte mask
		// -------------
		public const NAV_LOCATION					:int = 1;
		public const NAV_ALTITUDE					:int = 2;
		public const NAV_DELAY						:int = 4;

		// Waypoint options
		public const MASK_OPTIONS_RELATIVE_ALT 		:int = 1
		public const WP_OPTION_ALT_CHANGE 			:int = 2
		public const WP_OPTION_YAW 					:int = 4
		public const WP_OPTION_ALT_REQUIRED			:int = 8
		public const WP_OPTION_RELATIVE				:int = 16
		public const WP_OPTION_NEXT_CMD				:int = 128


		//repeating events
		public const NO_REPEAT 	 					:int = 0
		public const CH_5_TOGGLE  					:int = 1
		public const CH_6_TOGGLE  					:int = 2
		public const CH_7_TOGGLE  					:int = 3
		public const CH_8_TOGGLE  					:int = 4
		public const RELAY_TOGGLE  					:int = 5
		public const STOP_REPEAT 	 				:int = 10

		public const CH7_DO_NOTHING					:int = 0;
		public const CH7_SET_HOVER 					:int = 1;
		public const CH7_FLIP 						:int = 2;
		public const CH7_SIMPLE_MODE 				:int = 3;
		public const CH7_RTL 						:int = 4;
		public const CH7_AUTO_TRIM 					:int = 5;
		public const CH7_ADC_FILTER 				:int = 6;
		public const CH7_SAVE_WP 					:int = 7;
		public const CH_7_PWM_TRIGGER 	 			:int = 1800

		// --------------------------------------
		// Timers
		// --------------------------------------
		public var dTnav							:Number = 0.25;
		public var G_Dt								:Number = 0.01;
		public var m_dt								:Number = 0.02;
		public var elapsed							:int = 0;
		private var medium_loop_counter				:int = 0;
		private var fifty_toggle					:Boolean = false;
		private var medium_loopCounter				:int = 0;
		private var slow_loopCounter				:int = 0;
		private var superslow_loopCounter			:int = 0;
		private var auto_disarming_counter			:int = 0;
		private var last_gps_time					:int = 0;
		private var counter_one_herz				:int = 0;
		private var gps_watchdog					:int = 0;
		private var gps_fix_count					:int = 0;
		private var perf_mon_counter				:int = 0;



		////////////////////////////////////////////////////////////////////////////////
		// LED output
		////////////////////////////////////////////////////////////////////////////////
		// status of LED based on the motor_armed variable
		// Flashing indicates we are not armed
		// Solid indicates Armed state
		public var motor_light						:Boolean = false;
		// Flashing indicates we are reading the GPS Strings
		// Solid indicates we have full 3D lock and can navigate
		public var GPS_light						:Boolean = false;
		// This is current status for the LED lights state machine
		// setting this value changes the output of the LEDs
		public var led_mode  						:int = 0; //NORMAL_LEDS;
		// Blinking indicates GPS status
		public var copter_leds_GPS_blink 			:int = 0;
		// Blinking indicates battery status
		public var copter_leds_motor_blink	 		:int = 0;
		// Navigation confirmation blinks
		public var copter_leds_nav_blink 			:int = 0;

		public var baro								:Baro;
		public var sonar							:Sonar;
		public var next_WP							:Location;
		public var prev_WP							:Location;
		public var target_WP						:Location;
		public var guided_WP						:Location;
		public var current_loc						:Location;
		public var home								:Location;
		public var command_cond_queue				:Location;
		public var command_nav_queue				:Location;
		public var circle_WP						:Location;

		public var home_is_set						:Boolean;

		public var sensor_speed						:Vector3D;
		private var alt_sensor_flag					:Boolean;
		public var low_batt							:Boolean = false;
		public var GPS_enabled						:Boolean = true;
		public var event_undo_value					:Number = 0
		public var event_id							:int = 0

		public var event_timer						:Number = 0;
		public var event_value						:Number = 0;
		public var event_repeat						:Number = 0;
		public var event_delay						:Number = 0;
		public var scaleLongUp						:Number = 1;
		public var scaleLongDown					:Number = 1;

		// --------------------------------------
		// Plotting
		// --------------------------------------
		public var plotView							:PlotView;
		public var plot_A							:int = 0;
		public var plot_B							:int = 0;
		public var plotType_A						:String = "";
		public var plotType_B						:String = "";
		public var fastPlot							:Boolean = true;
		public var roll_output						:Number;

		// -----------------------------------------
		// Flight Modes
		// -----------------------------------------
		// The current desired control scheme for roll and pitch / navigation
		public var roll_pitch_mode					:int = 0;
		public var yaw_mode							:int = 0;
		public var yaw_output						:int = 0;

		// The current desired control scheme for altitude hold
		public var throttle_mode					:int = 0;
		public var throttle_avg						:Number = 0;
		public var takeoff_complete					:Boolean = false;

		public var circle_angle						:Number = 0;
		public var circle_rate						:Number = 0.0872664625;
		public var loiter_total						:Number = 0;
		public var loiter_sum						:Number = 0;
		public var loiter_time						:Number = 0;
		public var loiter_time_max					:Number = 0;
		public var rtl_reached_alt					:Boolean = false;

		////////////////////////////////////////////////////////////////////////////////
		// Toy Mode
		////////////////////////////////////////////////////////////////////////////////
		public const TOY_DELAY						:int = 500;	// Equal to 1.5 s at 100hz
		public var toy_input_timer					:int = 0; 	// A delay timer to engage loiter or WP mode
		public var toy_speed						:int = 0; 	// TO remember how fast we are going when we enage WP mode
		public var toy_lookup						:Array;
		public var toy_alt							:int = -1;
		public var toy_alt_hold						:Boolean;


		// -----------------------------------------
		// Simple Mode
		// -----------------------------------------
		public var do_simple						:Boolean = false;
		public var oldSwitchPosition				:int = 0;
		public var switch_debouncer					:Boolean = false;
		public var initial_simple_bearing			:int = 0;
		public var simple_counter					:int = 0;
		public var trim_flag						:Boolean = false;
		public var CH7_wp_index						:int = 0;
		public var simple_sin_y						:Number = 0;
		public var simple_cos_x						:Number = 0;


		// -----------------------------------------
		// Climb rate control
		// -----------------------------------------
		// Time when we intiated command in millis - used for controlling decent rate
		// The orginal altitude used to base our new altitude during decent
		public var original_altitude				:Number = 0;
		// Used to track the altitude offset for climbrate control
		public var target_altitude					:Number = 0;
		public var alt_change_timer					:Number = 0;
		public var alt_change_flag					:int = 0;
		public var alt_change						:Number = 0;

		public var nav_thrust_z						:Number = 0;
		public var d_alt_accel						:Number = 0;
		public var z_boost							:Number = 0;



		// -----------------------------------------
		// Loiter and NAV
		// -----------------------------------------
		public var desired_speed					:Number = 0;
		public var p_loiter_rate					:Number = 0;
		public var i_loiter_rate					:Number = 0;
		public var d_loiter_rate					:Number = 0;
		public var p_nav_rate						:Number = 0;
		public var i_nav_rate						:Number = 0;
		public var d_nav_rate						:Number = 0;
		public var nav_lon							:Number = 0;
		public var nav_lat							:Number = 0;
		public var nav_roll							:Number = 0;
		public var nav_pitch						:Number = 0;
		private var last_longitude					:Number	= 0;
		private var last_latitude					:Number	= 0;
		public var lon_filter						:AverageFilter;
		//public var xFilter							:AverageFilter;
		public var xLeadFilter						:LeadFilter;
		public var yLeadFilter						:LeadFilter;
		private var nav_ok							:Boolean = false;
		public var auto_roll						:Number = 0;
		public var auto_pitch						:Number = 0;
		public var slow_wp							:Boolean = false;
		public var waypoint_speed_gov				:int;
		public var loiter_timer						:int = 0;
		public var wp_control						:int = 0;
		public var wp_verify_byte					:int = 0;
		public var loiter_override					:Boolean = false;
		public var crosstrack_error					:Number = 0;
		public var crosstrack_score					:Number = 0;
		public var alt_hold_score					:Number = 0;
		public var long_error						:Number = 0;
		public var lat_error						:Number = 0;
		public var baro_alt							:Number	= 0;
		public var baro_rate						:Number	= 0;
		public var sonar_rate						:Number	= 0;
		public var sonar_alt						:Number	= 0;
		public var old_sonar_alt					:Number	= 0;
		public var old_baro_alt						:Number	= 0;
		public var wp_distance						:int = 0;
		public var home_distance					:int = 0;
		public var home_to_copter_bearing			:Number = 0;
		public var target_bearing					:Number = 0;
		public var old_target_bearing				:Number = 0;
		public var original_target_bearing			:Number = 0;
		public var jump								:int = -10;
		public var command_cond_index				:int = 0;
		public var prev_nav_index					:int = 0;
		public var command_nav_index				:int = 0;
		public var condition_value					:Number = 0;
		public var condition_start					:Number = 0;


		public var yaw_stopped						:Boolean = true;
		public var yaw_timer						:int = 0;


		public var nav_yaw							:Number = 0;
		public var auto_yaw							:Number = 0;
		public var yaw_tracking 					:int 	= 1; 		//MAV_ROI_WPNEXT;
		public var command_yaw_start				:Number = 0;
		public var command_yaw_start_time			:Number = 0;
		public var command_yaw_time					:Number = 0;
		public var command_yaw_end					:Number = 0;
		public var command_yaw_delta				:Number = 0;
		public var command_yaw_speed				:Number = 0;
		public var command_yaw_dir					:Number = 0;
		public var command_yaw_relative				:Number = 0;
		public var cos_roll_x						:Number = 1;
		public var cos_pitch_x						:Number = 1;
		public var cos_yaw_x						:Number = 1;
		public var sin_yaw_y						:Number = 0;

		public var accels_velocity					:Vector3D;
		public var accels_position					:Vector3D;
		public var accels_rotated					:Vector3D;

		public var speed_error						:Vector3D;
		public var position_error					:Vector3D;
		public var accels_scale						:Vector3D;
		public var offset_x_gain					:Number = 0;
		public var offset_y_gain					:Number = 0;
		public var offset_z_gain					:Number = 0;

		// -----------------------------------------
		// GPS Latency patch
		// -----------------------------------------
		private var speed_old						:Number = 0;

		// -----------------------------------------
		// GPS Latency patch
		// -----------------------------------------
		public var failsafeCounter					:int = 0;

		// -----------------------------------------
		// Acro
		// -----------------------------------------
		public var roll_axis						:Number = 0;
		public var pitch_axis						:Number = 0;
		public var do_flip							:Boolean = false;
		public var flip_timer						:int = 0;
		public var flip_state 						:int = 0;

		public const AAP_THR_INC					:int = 170;
		public const AAP_THR_DEC					:int = 90;
		public const AAP_ROLL_OUT					:int = 2000;

		// -----------------------------------------
		// Stabilize
		// -----------------------------------------
		public var p_stab							:Number = 0;
		public var i_stab							:Number = 0;
		public var p_stab_rate						:Number = 0;
		public var i_stab_rate						:Number = 0;
		public var d_stab_rate						:Number = 0;

		public var roll_rate_error					:Number = 0;
		public var pitch_rate_error					:Number = 0;

		public var roll_last_rate					:Number = 0;
		public var pitch_last_rate					:Number = 0;
		public var roll_servo_out					:Number = 0;
		public var pitch_servo_out					:Number = 0;
		public var roll_rate_d_filter				:AverageFilter;
		public var pitch_rate_d_filter				:AverageFilter;
		public var roll_scale_d						:Number = 0;
		public var pitch_scale_d					:Number = 0;

		public var rate_d_dampener					:Number = 0;
		public var control_roll						:Number = 0;
		public var control_pitch					:Number = 0;
		// -----------------------------------------
		// Altitude hold
		// -----------------------------------------
		public var angle_boost						:Number = 0;
		public var manual_boost						:Number = 0;
		public var nav_throttle						:Number = 0;
		public var z_target_speed					:Number = 0;
		public var i_hold							:Number = 0;
		public var p_alt_rate						:Number = 0;
		public var i_alt_rate						:Number = 0;
		public var d_alt_rate						:Number = 0;
		public var z_rate_error						:Number = 0;

		public var last_error						:Number	= 0;
		public var throttle							:Number = 0;
		public var err								:Number = 0;
		public var altitude_error					:Number = 0;
		public var old_altitude						:Number = 0;
		public var old_alt							:Number = 0;
		public var reset_throttle_flag				:Boolean = false;

		public var climb_rate						:Number = 0;
		public var climb_rate_avg					:Number = 0;
		public var climb_rate_actual				:Number = 0;
		public var climb_rate_error					:Number = 0;
		public var landing_boost					:Number = 0;
		public var land_complete					:Boolean = false;
		public var ground_detector					:int = 0;

		public function Main():void
		{
			user 					= new User(); // recorded flight input
			copter 					= new Copter(); // recorded flight input
			ahrs					= new AHRS();
			apm_rc					= new APM_RC();
			g_gps					= new GPS(copter.loc);
			baro					= new Baro(copter.loc);
			sonar					= new Sonar(copter.loc);

			next_WP					= new Location();
			current_loc				= new Location();
			home					= new Location();
			guided_WP				= new Location();
			target_WP				= new Location();
			circle_WP				= new Location();

			sensor_speed			= new Vector3D();
			accels_velocity			= new Vector3D();
			accels_position			= new Vector3D();
			speed_error				= new Vector3D();
			position_error			= new Vector3D();

			accels_scale			= new Vector3D();
			accels_rotated			= new Vector3D();
			lon_filter				= new AverageFilter(g.speed_filter_size);
			//xFilter					= new AverageFilter(6);
			roll_rate_d_filter		= new AverageFilter(3);
			pitch_rate_d_filter		= new AverageFilter(3);
			xLeadFilter				= new LeadFilter();
			yLeadFilter				= new LeadFilter();
			motors					= new Motors();
			waypoints				= new Array();

			motor_out				= new Array();

			copter.ahrs				= ahrs;
			copter.apm_rc			= apm_rc;

			// AP queues
			command_nav_queue 		= new Location();
			command_cond_queue 		= new Location();


			toy_lookup = new Array(	186, 	373, 	558, 	745,
									372, 	745, 	1117, 	1490,
									558, 	1118, 	1675, 	2235,
									743, 	1490, 	2233, 	2980,
									929, 	1863, 	2792, 	3725,
									1115, 	2235, 	3350, 	4470,
									1301, 	2608, 	3908, 	4500,
									1487, 	2980, 	4467, 	4500,
									1673, 	3353, 	4500, 	4500);

			//sky.s = next_WP;
			sky.copter 		= copter;
			sky.controller 	= this;
			sky.current_loc = this.current_loc;

			ground.copter 		= copter;
			ground.controller 	= this;
			ground.current_loc 	= this.current_loc;


			//THOR Added for additional Fligt mode
			flight_mode_strings = new Array("STABILIZE","ACRO","ALT_HOLD","AUTO","GUIDED","LOITER","RTL","CIRCLE","POSITION","LAND","OF_LOITER","TOY");
			flight_modes = new Array(0,1,2,3,4,5,6,7,8,9,10,11,12);

			colors = new Array(0xD6C274, 0xDB9E46, 0x95706B, 0x9D2423, 0x7B962E, 0xB5BC87, 0x7EBC5F, 0x74287D, 0x765A70, 0xA82DBC, 0xD9B64E, 0xF28B50, 0xF25E3D, 0x79735E, 0x6D78F4);
			populateMenus(plotMenu);
			populateMenus(plotMenu2);

			modeMenu.addItem(new QuickMenuItem("0  STABILIZE",	"0"));
			modeMenu.addItem(new QuickMenuItem("1  ACRO",		"1"));
			modeMenu.addItem(new QuickMenuItem("2  ALT_HOLD",	"2"));
			modeMenu.addItem(new QuickMenuItem("3  AUTO",		"3"));
			modeMenu.addItem(new QuickMenuItem("4  GUIDED",		"4"));
			modeMenu.addItem(new QuickMenuItem("5  LOITER",		"5"));
			modeMenu.addItem(new QuickMenuItem("6  RTL",		"6"));
			modeMenu.addItem(new QuickMenuItem("7  CIRCLE",		"7"));
			modeMenu.addItem(new QuickMenuItem("8  POSITION",	"8"));
			modeMenu.addItem(new QuickMenuItem("9  LAND",		"9"));
			modeMenu.addItem(new QuickMenuItem("10 OF_LOITER",	"10"));
			modeMenu.addItem(new QuickMenuItem("11 TOY",		"11"));

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	    }


	    public function populateMenus(m:QuickPopupMenu):void
		{
			// Stability
			m.addItem(new QuickMenuItem("Roll Sensor",			"roll_sensor"));
			m.addItem(new QuickMenuItem("Pitch Sensor",			"pitch_sensor"));
			m.addItem(new QuickMenuItem("Desired Roll",			"control_roll"));

			/*
			m.addItem(new QuickMenuItem("Roll Error", 			"roll_error"));
			m.addItem(new QuickMenuItem("Stabilize P", 			"stab_p"));
			m.addItem(new QuickMenuItem("Stabilize I", 			"stab_i"));

			m.addItem(new QuickMenuItem("Rate Roll Error", 		"roll_rate_error"));
			m.addItem(new QuickMenuItem("Stabilize Rate P", 	"rate_p"));
			m.addItem(new QuickMenuItem("Stabilize Rate I", 	"rate_i"));
			m.addItem(new QuickMenuItem("Stabilize Rate D", 	"rate_d"));
			m.addItem(new QuickMenuItem("Stabilize Dampener", 	"rate_damp"));
			m.addItem(new QuickMenuItem("Roll Output", 			"roll_output"));

			m.addDivider(new QuickMenuDivider());
			*/

			m.addItem(new QuickMenuItem("Stab Yaw I", 			"yaw_i"));
			m.addItem(new QuickMenuItem("Rate Yaw I", 			"rate_yaw_i"));
			m.addItem(new QuickMenuItem("Yaw Out", 				"yaw_out"));

			m.addDivider(new QuickMenuDivider());

			// Alt Hold
			m.addItem(new QuickMenuItem("Altitude",				"altitude"));
			m.addItem(new QuickMenuItem("Next WP Alt",			"next_wp_alt"));
			m.addItem(new QuickMenuItem("Altitude Err",			"altitude_error"));
			m.addItem(new QuickMenuItem("Actual Altitude Err",	"act_altitude_error"));
			m.addItem(new QuickMenuItem("Desired Climb Rate",	"z_target_speed"));
			m.addItem(new QuickMenuItem("Alt Hold I",			"alt_hold_i"));

			m.addItem(new QuickMenuItem("Climb Rate Error",		"z_rate_error"));
			m.addItem(new QuickMenuItem("Alt Hold Rate P",		"alt_rate_p"));
			m.addItem(new QuickMenuItem("Alt Hold Rate I",		"alt_rate_i"));
			m.addItem(new QuickMenuItem("Alt Hold Rate D",		"alt_rate_d"));
			m.addItem(new QuickMenuItem("Accel D",				"d_alt_accel"));

			m.addDivider(new QuickMenuDivider());

			// AP
			m.addItem(new QuickMenuItem("WP Distance", 			"wp_distance"));
			m.addItem(new QuickMenuItem("X Long Error", 		"long_error"));
			m.addItem(new QuickMenuItem("X Actual Speed", 		"x_speed"));
			m.addItem(new QuickMenuItem("X Target Speed",		"x_target_speed"));
			m.addItem(new QuickMenuItem("X Rate Error", 		"x_rate_error"));

			m.addItem(new QuickMenuItem("Y Actual Speed", 		"y_speed"));
			m.addItem(new QuickMenuItem("Y Target Speed",		"y_target_speed"));
			m.addItem(new QuickMenuItem("Y Rate Error", 		"y_rate_error"));
			m.addDivider(new QuickMenuDivider());

			// Loiter
			m.addItem(new QuickMenuItem("Loiter Lon Rate P", 		"loiter_rate_p"));
			m.addItem(new QuickMenuItem("Loiter Lon Rate I", 		"loiter_rate_i"));
			m.addItem(new QuickMenuItem("Loiter Lon Rate D", 		"loiter_rate_d"));
			m.addDivider(new QuickMenuDivider());

			// Nav
			m.addItem(new QuickMenuItem("Nav Lon Rate P", 			"nav_lon_rate_p"));
			m.addItem(new QuickMenuItem("Nav Lon Rate I", 			"nav_lon_rate_i"));
			m.addItem(new QuickMenuItem("Nav Lon Rate D", 			"nav_lon_rate_d"));

			m.addDivider(new QuickMenuDivider());

			m.addItem(new QuickMenuItem("Nav Roll",		 		"nav_lon"));
			m.addItem(new QuickMenuItem("Nav Pitch",		 	"nav_lat"));
			m.addItem(new QuickMenuItem("Groudn Speed",		 	"ground_speed"));


			m.addItem(new QuickMenuItem("Nav Lat Rate I", 		"nav_lat_rate_i"));
			m.addItem(new QuickMenuItem("Y Lat Error", 			"lat_error"));
			m.addDivider(new QuickMenuDivider());

			//m.addItem(new QuickMenuItem("Accel Velocity X",		"vel_x"));

			m.addItem(new QuickMenuItem("Accel Vel Err X",		"vel_x"));
			m.addItem(new QuickMenuItem("Accel Pos Err X",		"pos_x"));
			m.addItem(new QuickMenuItem("Accel Offset X",		"off_x"));

			m.addItem(new QuickMenuItem("Accel Vel Err Z",		"vel_z"));
			m.addItem(new QuickMenuItem("Accel Pos Err Z",		"pos_z"));
			m.addItem(new QuickMenuItem("Accel Offset Z",		"off_z"));
			m.addItem(new QuickMenuItem("Accel Offset Gain Z",		"off_g_z"));
			m.addDivider(new QuickMenuDivider());


			m.addItem(new QuickMenuItem("throttle Cruise",		"throttle_cruise"));
			m.addItem(new QuickMenuItem("Angle Boost",			"angle_boost"));
			m.addItem(new QuickMenuItem("Throttle Output",		"throttle_out"));
			m.addItem(new QuickMenuItem("Motor 1",				"motor_1"));
			m.addItem(new QuickMenuItem("Motor 2",				"motor_2"));

			m.addItem(new QuickMenuItem("Wind Speed",			"wind_speed"));
			m.addItem(new QuickMenuItem("Yaw Sensor",			"yaw_sensor"));

			m.addDivider(new QuickMenuDivider());

			m.addItem(new QuickMenuItem("Target Angle",			"t_angle"));
			m.addItem(new QuickMenuItem("Target Angle Err",		"t_angle_err"));
			m.addItem(new QuickMenuItem("Crosstrack error",		"crosstrack_error"));



		}

	    public function addedToStage(even:Event):void
		{
            stage.scaleMode		= StageScaleMode.NO_SCALE;
          	stage.align			= StageAlign.TOP_LEFT;

			g = Parameters.getInstance();
			g.controller = this;
			g.visible = false;

			wp_manager.set_waypoint_array(waypoints);
			wp_manager.controller = this;

			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);

			sim_controller.setLabel("START SIM");
			sim_controller.setEventName("RUN_SIM");
			stage.addEventListener("RUN_SIM",simHandler);

			graph_button.setLabel("Clear Graph");
			graph_button.setEventName("CLEAR_GRAPH");
			stage.addEventListener("CLEAR_GRAPH",graphHandler);

			joystick_button.setLabel("Show Joysticks");
			joystick_button.setEventName("JOYSTICKS");
			stage.addEventListener("JOYSTICKS",joyHandler);

			waypoint_button.setLabel("Show Waypoints");
			waypoint_button.setEventName("WAYPOINTS");
			stage.addEventListener("WAYPOINTS",wpHandler);

			arm_button.setLabel("ARM");
			arm_button.setEventName("ARM");
			stage.addEventListener("ARM",armHandler);

			plotMenu.setEventName("PLOT_MENU");
			plotMenu2.setEventName("PLOT_MENU");
			stage.addEventListener("PLOT_MENU",plotMenuHandler);


			modeMenu.setEventName("MODE_MENU");
			stage.addEventListener("MODE_MENU",modeMenuHandler);

			gains_button.setEventName("TOGGLE_GAINS");
			gains_button.setLabel("Show Gains");
			stage.addEventListener("TOGGLE_GAINS", gainsHandler);


			// setup radio
			//rc_throttle.sticky = true;
			//right_sticks.sticky_x = true;
			//right_sticks.sticky_y = true;
			left_sticks.sticky_y = true;
			left_sticks.sticky_x = true;

			init_sim();

			// PLOTTING
			//addChildAt(plotView, 0);
			plotView.dataScaleY		= 0.25
			plotView.dataScaleX		= 3.0

			left_sticks.visible = false;
			right_sticks.visible = false;

			plotMenu.setSelectedItemByName("WP Distance");
			plotMenu.setSelectedItemByName("Roll Sensor");

			this.addEventListener(Event.ENTER_FRAME, idle);
		}

		public function idle(e:Event):void
		{
			if(medium_loop_counter++ >= 50){
				medium_loop_counter	= 0;
				user_settings_sim();
				home_is_set = true;
				//air_start();
				//update_altitude();
				//next_WP.lng				= g.target_distance_BI.getNumber();
				//next_WP.alt				= g.target_altitude_BI.getNumber();
				//copter.position.z		= copter.loc.alt = g.start_height_BI.getNumber(); // add in some delay

				//if(g.start_position_BI.getNumber() != 0)
				//	copter.position.x = g.start_position_BI.getNumber();
				sky.draw();
				ground.draw();
				sky.failsafe_MC.visible = false;
			}

			if (g_gps.new_data == true){
				g_gps.new_data = false;
				update_GPS();
				iteration = 0;
			}
		}

		public function runSim(e:Event):void
		{
			// 50hz update
			update_sim_radio();

			// run 2x to get 100hz updates
			for(var i:int = 0; i < (g.sim_speed * 2); i++){
				g_gps.read();// fake a GPS read
				loop();
				elapsed += 10; // 50 * 20  = 1000 ms
			}
			sky.draw();
			ground.draw()
			sky.failsafe_MC.visible = radio_failure;
		}


		public function loop():void
		{
			iteration++;

			fast_loop();
			// 50 hz pieces
			if(fifty_toggle){


				if(iteration > g.sim_iterations){
					stopSIM();
				}

				// reads all of the necessary trig functions for cameras, throttle, etc.
				// --------------------------------------------------------------------
				update_trig();

				// Rotate the Nav_lon and nav_lat vectors based on Yaw
				// ---------------------------------------------------
				calc_loiter_pitch_roll();

				// check for new GPS messages
				// --------------------------
				update_GPS();

				// perform 10hz tasks
				// ------------------
				medium_loop();

				counter_one_herz++;

				// trgger our 1 hz loop
				if(counter_one_herz >= 50){
					super_slow_loop();
					counter_one_herz = 0;

					//offset_x_gain *= 0.95;
					//offset_y_gain *= 0.95;
					//offset_z_gain *= 0.95;

					//offset_x_gain = Math.max(offset_x_gain, 0);
					//offset_y_gain = Math.max(offset_y_gain, 0);
					//offset_z_gain = Math.max(offset_z_gain, 0);

					//trace(offset_x_gain, offset_y_gain, offset_z_gain);
				}

				// Stuff to run at full 50hz, but after the med loops
				// --------------------------------------------------
				fifty_hz_loop();

				if(fastPlot){
					plot(plotType_A, plot_A , 1);
					plot(plotType_B, plot_B , 2);
				}
			}
			fifty_toggle = !fifty_toggle;

			// reposition Copter onscreen
			copter.update(G_Dt);
		}


		public function fast_loop():void
		{

			// Read radio
			// ----------
			read_radio();

			// IMU DCM Algorithm
			// --------------------
			//read_AHRS();

			if(g.inertia_checkbox.getSelected())
				calc_inertia();

			// custom code/exceptions for flight modes
			// ---------------------------------------
			update_yaw_mode();
			update_roll_pitch_mode();

			// write out the servo PWM values
			// ------------------------------
			set_servos_4();
		}

		public function medium_loop():void
		{
			// This is the start of the medium (10 Hz) loop pieces
			// -----------------------------------------
			switch(medium_loopCounter) {

				// This case deals with the GPS and Compass
				//-----------------------------------------
				case 0:
					alt_hold_score += Math.abs((next_WP.alt - current_loc.alt) * .01); // for judging

					if(fastPlot == false){
						plot(plotType_A, plot_A , 1);
						plot(plotType_B, plot_B , 2);
					}
					sky.toy_alt_hold_MC.visible = (throttle_mode > THROTTLE_MANUAL);


					medium_loopCounter++;
					elapsed_time_tf.text = formatTime(elapsed) + " " + iteration.toString();

					//debug_TF.text = x_actual_speed +"\n"+ x_target_speed.toFixed(2) + "\n" + x_rate_error.toFixed(2)  + "\n" +ahrs.roll_sensor.toFixed(2)+"\n"+ p_loiter_rate.toFixed(2)  + "\n" + i_loiter_rate.toFixed(2) + "\n" + d_loiter_rate.toFixed(2) ;
					debug_TF.text =   	current_loc.alt.toFixed(0) +"\n" +
										current_loc.lng.toFixed(0) +"\n" +
										current_loc.lat.toFixed(0) +"\n" +
										climb_rate_avg.toFixed(0) +"\n" +
										x_actual_speed.toFixed(0) +"\n" +
										y_actual_speed.toFixed(0) +"\n" +
										crosstrack_score.toFixed(0) +"\n" +
										alt_hold_score.toFixed(0);

					// record throttle output
					// ------------------------------
					throttle_integrator += g.rc_3.servo_out;
					break;

				// This case performs some navigation computations
				//------------------------------------------------
				case 1:
					medium_loopCounter++;

					// calculate the copter's desired bearing and WP distance
					// ------------------------------------------------------
					if(nav_ok){
						// clear nav flag
						nav_ok = false;

						// calculate distance, angles to target
						navigate();

						// update flight control system
						update_navigation();

						if(g.NTUN_checkbox.getSelected()){
							Log_Write_Nav_Tuning();
						}

						if(g.ATT_checkbox.getSelected())
							Log_Write_Attitude();

					}
					break;

				// command processing
				//-------------------
				case 2:
					medium_loopCounter++;
					alt_sensor_flag = true;
					break;

				// This case deals with sending high rate telemetry
				//-------------------------------------------------
				case 3:
					medium_loopCounter++;

					// perform next command
					// --------------------
					if(control_mode == AUTO){
						if(home_is_set == true && g.command_total > 1){
							update_commands();
						}
					}

					if(motors.armed){
						//if (g.log_bitmask & MASK_LOG_ATTITUDE_MED)
						// increment user input
						//user.next_roll();

						//if(g.ATT_checkbox.getSelected())
						//	Log_Write_Attitude();

						//if (g.log_bitmask & MASK_LOG_MOTORS)
						//	Log_Write_Motors();
					}
					break;

				// This case controls the slow loop
				//---------------------------------
				case 4:
					medium_loopCounter = 0;
					// Accel trims 		= hold > 2 seconds
					// Throttle cruise  = switch less than 1 second
					// --------------------------------------------
					read_trim_switch();

					slow_loop();
					break;

				default:
					// this is just a catch all
					// ------------------------
					medium_loopCounter = 0;
					break;
			}
		}

		// stuff that happens at 50 hz
		// ---------------------------
		public function fifty_hz_loop():void
		{
			// read altitude sensors or estimate altitude
			// ------------------------------------------
			update_altitude_est();

			// moved to slower loop
			// --------------------
			update_throttle_mode();

			// Read Sonar
			// ----------
			if(g.sonar_enabled){
				sonar_alt = sonar.read();
			}
		}

		public function slow_loop():void
		{
			// This is the slow (3 1/3 Hz) loop pieces
			//----------------------------------------
			switch (slow_loopCounter){
				case 0:
					slow_loopCounter++;
					superslow_loopCounter++;

					//trace(ahrs.roll_sensor, Math.floor(g.rc_1.servo_out), ahrs.pitch_sensor, Math.floor(g.rc_2.servo_out));

					if(superslow_loopCounter > 1200){
						// save compass offsets
						superslow_loopCounter = 0;
					}
					// XXX SYNC - auto throttle changing
					//g.rc_3.set_range((g.throttle_cruise - (g.throttle_max - g.throttle_cruise)), g.throttle_max);
					//g.rc_3.set_range_out(0,1000);


					// reduce offset gains
					if(g.inertia_checkbox.getSelected()){



					}


					// check the user hasn't updated the frame orientation
					//if( !motors.armed ) {
						//motors.set_frame_orientation(g.frame_orientation);
					//}

					break;

				case 1:
					slow_loopCounter++;

					// Read 3-position switch on radio
					// -------------------------------
					read_control_switch();

					// agmatthews - USERHOOKS
					//#ifdef USERHOOK_SLOWLOOP
					//   USERHOOK_SLOWLOOP
					//#endif

					break;

				case 2:
					slow_loopCounter = 0;
					update_events();

					// blink if we are armed
					//update_lights();

					break;

				default:
					slow_loopCounter = 0;
					break;
			}
		}

		public function super_slow_loop():void
		{
			// this function disarms the copter if it has been sitting on the ground for any moment of time greater than 25 seconds
			// but only of the control mode is manual
			if((control_mode <= ACRO) && (g.rc_3.control_in == 0)){
				auto_disarming_counter++;

				if(auto_disarming_counter == AUTO_DISARMING_DELAY){
					init_disarm_motors();
				}else if (auto_disarming_counter > AUTO_DISARMING_DELAY){
					auto_disarming_counter = AUTO_DISARMING_DELAY + 1;
				}
			}else{
				auto_disarming_counter = 0;
			}
		}

		public function update_GPS()
		{
			if(g_gps.new_data == true){
				//iteration++;
				g_gps.new_data = false;
				nav_ok = true;

				// we read  GPS every 250 ms
				dTnav = .25;

				//current_loc.lng = g_gps.longitude// + x_actual_speed/2;
				//current_loc.lat = g_gps.latitude;
				calc_XY_velocity();
				if(g.GPS_checkbox.getSelected())
					Log_Write_GPS();
			}else{
				// dead reckon


				if(g.inertia_checkbox.getSelected()){
					//nav_ok = true;
					//dTnav = .02;

				}
			}
		}


		public function update_yaw_mode():void
		{
			switch(yaw_mode){
				case YAW_ACRO:
					g.rc_4.servo_out = get_acro_yaw(g.rc_4.control_in);
					return;
					break;

				case YAW_HOLD:
					if(g.rc_4.control_in != 0){
						g.rc_4.servo_out = get_acro_yaw(g.rc_4.control_in);
						yaw_stopped = false;
						yaw_timer = 150;
					}else if (!yaw_stopped){
						g.rc_4.servo_out = get_acro_yaw(0);
						yaw_timer--;
						if(yaw_timer == 0){
							yaw_stopped = true;
							nav_yaw = ahrs.yaw_sensor;
						}
					}else{
						nav_yaw = get_nav_yaw_offset(g.rc_4.control_in, g.rc_3.control_in);
						g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
					}
					return;
					break;

				case YAW_LOOK_AT_HOME:
					//nav_yaw updated in update_navigation()
					g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
					break;

				case YAW_AUTO:
					nav_yaw += constrain(wrap_180(auto_yaw - nav_yaw), -60, 60); // 40 deg a second
					//Serial.printf("nav_yaw %d ", nav_yaw);
					nav_yaw  = wrap_360(nav_yaw);
					// Yaw output
					g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
					break;
			}
		}

		public function update_roll_pitch_mode():void
		{
			//var control_roll:Number = 0;
			if (do_flip){
				if(g.rc_1.control_in == 0){
					roll_flip();
					return;
				}else{
					do_flip = false;
				}
			}

			switch(roll_pitch_mode){
				case ROLL_PITCH_ACRO:
					if(g.axis_enabled){
						roll_axis 	+= g.rc_1.control_in * g.axis_lock_p;
						pitch_axis 	+= g.rc_2.control_in * g.axis_lock_p;

						roll_axis = wrap_360(roll_axis);
						pitch_axis = wrap_360(pitch_axis);

						control_roll = roll_axis; // for debugging

						// in this mode, nav_roll and nav_pitch = the iterm
						g.rc_1.servo_out = get_stabilize_roll(roll_axis);
						g.rc_2.servo_out = get_stabilize_pitch(pitch_axis);

						if (g.rc_3.control_in == 0){
							roll_axis = 0;
							pitch_axis = 0;
						}

					}else{
						control_roll = g.rc_1.control_in; // for debugging
						// ACRO does not get SIMPLE mode ability
						g.rc_1.servo_out = get_acro_roll(g.rc_1.control_in);
						g.rc_2.servo_out = get_acro_pitch(g.rc_2.control_in);
					}
					break;

				case ROLL_PITCH_STABLE:
					// apply SIMPLE mode transform
					if(do_simple && new_radio_frame){
						update_simple_mode();
					}

					// in this mode, nav_roll and nav_pitch = the iterm
					g.rc_1.servo_out = get_stabilize_roll(g.rc_1.control_in);
					g.rc_2.servo_out = get_stabilize_pitch(g.rc_2.control_in);
					control_roll = g.rc_1.control_in; // debugging
					break;

				case ROLL_PITCH_AUTO:
					// apply SIMPLE mode transform
					if(do_simple && new_radio_frame){
						update_simple_mode();
					}
					// mix in user control with Nav control
					nav_roll			+= constrain(wrap_180(auto_roll  - nav_roll),  -g.auto_slew_rate, g.auto_slew_rate); // 40 deg a second
					nav_pitch			+= constrain(wrap_180(auto_pitch - nav_pitch), -g.auto_slew_rate, g.auto_slew_rate); // 40 deg a second

					control_roll 		= g.rc_1.control_mix(nav_roll);
					control_pitch 		= g.rc_2.control_mix(nav_pitch);
					g.rc_1.servo_out 	= get_stabilize_roll(control_roll);
					g.rc_2.servo_out 	= get_stabilize_pitch(control_pitch);
					break;

				/*case ROLL_PITCH_STABLE_OF:
					// apply SIMPLE mode transform
					if(do_simple && new_radio_frame){
						update_simple_mode();
					}
					// mix in user control with optical flow
					g.rc_1.servo_out = get_stabilize_roll(get_of_roll(g.rc_1.control_in));
					g.rc_2.servo_out = get_stabilize_pitch(get_of_pitch(g.rc_2.control_in));
					break;*/

				// THOR
				// a call out to the main toy logic
				case ROLL_PITCH_TOY:
					roll_pitch_toy();
					break;
			}

			if(g.rc_3.control_in == 0 && roll_pitch_mode <= ROLL_PITCH_ACRO){
				reset_rate_I();
				reset_stability_I();
			}

			if(takeoff_complete == false){
				// reset these I terms to prevent awkward tipping on takeoff
				//reset_rate_I();
				//reset_stability_I();
			}

			if(new_radio_frame){
				// clear new radio frame info
				new_radio_frame = false;

				// These values can be used to scale the PID gains
				// This allows for a simple gain scheduling implementation
				roll_scale_d	= g.stabilize_d_schedule * Math.abs(g.rc_1.control_in);
				roll_scale_d	= (1 - (roll_scale_d / 4500.0));
				roll_scale_d	= constrain(roll_scale_d, 0, 1) * g.stabilize_d;

				pitch_scale_d	= g.stabilize_d_schedule * Math.abs(g.rc_2.control_in);
				pitch_scale_d 	= (1 - (pitch_scale_d / 4500.0));
				pitch_scale_d 	= constrain(pitch_scale_d, 0, 1) * g.stabilize_d;
			}
		}

		// new radio frame is used to make sure we only call this at 50hz
		public function update_simple_mode():void
		{
			//var simple_sin_y:Number = 0;
			//var simple_cos_x:Number = 0;

			// used to manage state machine
			// which improves speed of function
			simple_counter++;

			var delta:int = wrap_360(ahrs.yaw_sensor - initial_simple_bearing)/100;

			if (simple_counter == 1){
				// roll
				simple_cos_x = Math.sin(radians(90 - delta));

			}else if (simple_counter > 2){
				// pitch
				simple_sin_y = Math.cos(radians(90 - delta));
				simple_counter = 0;
			}

			// Rotate input by the initial bearing
			var control_roll:int 	= g.rc_1.control_in   * simple_cos_x + g.rc_2.control_in * simple_sin_y;
			var control_pitch:int 	= -(g.rc_1.control_in * simple_sin_y - g.rc_2.control_in * simple_cos_x);

			g.rc_1.control_in = control_roll;
			g.rc_2.control_in = control_pitch;
		}

		// 50 hz update rate
		// controls all throttle behavior
		public function update_throttle_mode():void
		{
			var throttle_out:Number = 0;

			//recalc throttle range

			switch(throttle_mode){
				case THROTTLE_MANUAL:
					if (g.rc_3.control_in > 0){
						if (control_mode == ACRO){
							g.rc_3.servo_out 	= g.rc_3.control_in;
						}else{
							angle_boost 		= get_angle_boost(g.rc_3.control_in);
							g.rc_3.servo_out 	= g.rc_3.control_in + angle_boost;
						}

						// ensure throttle_avg has been initialised
						if( throttle_avg == 0 ) {
							throttle_avg = g.throttle_cruise;
						}

						// calc average throttle
						if ((g.rc_3.control_in > g.throttle_min) && Math.abs(climb_rate_avg) < 40){
							throttle_avg = throttle_avg * .99 + g.rc_3.control_in * .01;
							g.throttle_cruise = throttle_avg;
						}

						if (takeoff_complete == false && motors.armed){
							if (g.rc_3.control_in > g.throttle_cruise){
								// we must be in the air by now
								takeoff_complete = true;
							}
						}

					}else{

						// make sure we also request 0 throttle out
						// so the props stop ... properly
						// ----------------------------------------
						g.rc_3.servo_out = 0;
					}
					break;

				case THROTTLE_HOLD:
					// allow interactive changing of atitude
					adjust_altitude();

					// fall through

				case THROTTLE_AUTO:
					// calculate angle boost
					angle_boost = get_angle_boost(g.throttle_cruise);

					// manual command up or down?
					if(manual_boost != 0){
						throttle_out = g.throttle_cruise + angle_boost + manual_boost;

						//force a reset of the altitude change
						clear_new_altitude();

						// this lets us know we need to update the altitude after manual throttle control
						reset_throttle_flag = true;

					}else{
						// we are under automatic throttle control
						// ---------------------------------------
						if(reset_throttle_flag)	{
							force_new_altitude(Math.max(current_loc.alt, 100));
							reset_throttle_flag = false;
							update_throttle_cruise();
						}

						// 10hz, 			don't run up i term
						if(motors.auto_armed == true){

							// how far off are we
							altitude_error = get_altitude_error();

							// SYNC
							if(g.test){
								// get the AP throttle
								//nav_throttle = get_nav_throttle(altitude_error);
								var desired_speed:Number;
								if(alt_change_flag == REACHED_ALT){ // we are at or above the target alt
									desired_speed 		= g.pi_alt_hold.get_p(altitude_error);			// calculate desired speed from lon error
									desired_speed		= constrain(desired_speed, -250, 250);
									nav_throttle 		= get_throttle_rate(desired_speed);
								}else{
									desired_speed 		= get_desired_climb_rate(150);
									nav_throttle 		= get_throttle_rate(desired_speed);
								}
							}else{
								// get the AP throttle
								nav_throttle = get_nav_throttle(altitude_error);
							}
						}

						// hack to remove the influence of the ground effect
						if(g.sonar_enabled && current_loc.alt < 100 && landing_boost != 0) {
							nav_throttle = Math.min(nav_throttle, 0);
						}

						//z_boost = get_z_boost();
						//z_boost = 0;
						throttle_out = g.throttle_cruise + nav_throttle + angle_boost - landing_boost;
					}

					// light filter of output
					//g.rc_3.servo_out = (g.rc_3.servo_out * (THROTTLE_FILTER_SIZE - 1) + throttle_out) / THROTTLE_FILTER_SIZE;

					// no filter
					g.rc_3.servo_out = throttle_out;
					break;
			}
		}

		//public function get_z_boost():Number
		//{
		//	return (ahrs.accel.z * 100) / (981 / g.throttle_cruise);
		//}

		// called after a GPS read
		public function update_navigation():void
		{
			// wp_distance is in CM
			// --------------------
			switch(control_mode){
				case AUTO:
					// note: wp_control is handled by commands_logic
					verify_commands();

					// calculates desired Yaw
					update_auto_yaw();

					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

				case GUIDED:
					wp_control = WP_MODE;
					// check if we are close to point > loiter
					wp_verify_byte = 0;
					verify_nav_wp();

					if (wp_control == WP_MODE) {
						update_auto_yaw();
					} else {
						set_mode(LOITER);
					}
					update_nav_wp();
					break;

				case RTL:
					// have we reached the desired Altitude?
					if(alt_change_flag <= REACHED_ALT){ // we are at or above the target alt

						if(rtl_reached_alt == false){
							rtl_reached_alt = true;
							do_RTL();
						}
						wp_control = WP_MODE;
						// checks if we have made it to home
						update_nav_RTL();
					} else{
						// we need to loiter until we are ready to come home
						wp_control = LOITER_MODE;
					}

					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

					// switch passthrough to LOITER
				case LOITER:
				case POSITION:
					// This feature allows us to reposition the quad when the user lets
					// go of the sticks

					if((Math.abs(g.rc_2.control_in) + Math.abs(g.rc_1.control_in)) > 500){
						if(wp_distance > 500)
							loiter_override 	= true;
					}

					// Allow the user to take control temporarily,
					if(loiter_override){
						// this sets the copter to not try and nav while we control it
						wp_control 	= NO_NAV_MODE;

						// reset LOITER to current position
						next_WP.lat = current_loc.lat;
						next_WP.lng = current_loc.lng;

						if(g.rc_2.control_in == 0 && g.rc_1.control_in == 0){
							loiter_override 	= false;
							wp_control 			= LOITER_MODE;
						}
					}else{
						wp_control = LOITER_MODE;
					}

					if(loiter_timer != 0){
						// If we have a safe approach alt set and we have been loitering for 20 seconds(default), begin approach
						if((millis() - loiter_timer) > g.auto_land_timeout){
							// just to make sure we clear the timer
							loiter_timer = 0;
							if(g.rtl_approach_alt == 0){
								set_mode(LAND);
								if(home_distance < 300){
									next_WP.lat = home.lat;
									next_WP.lng = home.lng;
								}
							}else{
								if(g.rtl_approach_alt < current_loc.alt){
									set_new_altitude(g.rtl_approach_alt);
								}
							}
						}
					}

					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

				case LAND:
					if(g.sonar_enabled)
						verify_land_sonar();
					else
						verify_land_baro();

					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

				case CIRCLE:
					wp_control 		= CIRCLE_MODE;

					// calculates desired Yaw
					update_auto_yaw();
					update_nav_wp();
					break;

				case STABILIZE:
					wp_control = NO_NAV_MODE;
					update_nav_wp();
					break;

				// THOR added to enable Virtual WP nav
				case TOY:
					update_nav_wp();
					break;
			}

			// are we in SIMPLE mode?
			if(do_simple && g.super_simple){
				// get distance to home
				if(home_distance > 1000){ // 10m from home
					// we reset the angular offset to be a vector from home to the quad
					initial_simple_bearing = home_to_copter_bearing;
					//Serial.printf("ISB: %d\n", initial_simple_bearing);
				}
			}

			if(yaw_mode == YAW_LOOK_AT_HOME){
				if(home_is_set){
					//nav_yaw = point_at_home_yaw();
					nav_yaw = get_bearing(current_loc, home);
				} else {
					nav_yaw = 0;
				}
			}
		}

		public function update_nav_RTL()
		{
			// We have reached Home
			if(wp_distance <= (g.waypoint_radius * 100)){
				// if loiter_timer value > 0, we are set to trigger auto_land or approach
				set_mode(LOITER);
				// just incase we arrive and we aren't at the lower RTL alt yet.

				set_new_altitude(get_RTL_alt());

				// force loitering above home
				next_WP.lat = home.lat;
				next_WP.lng = home.lng;

				// If land is enabled OR failsafe OR auto approach altitude is set
				// we will go into automatic land, (g.rtl_approach_alt) is the lowest point
				if(failsafe || g.rtl_approach_alt >= 0)
					loiter_timer = millis();
				else
					loiter_timer = 0;
			}

			slow_wp = true;
		}
		//static void read_AHRS(void)

		public function update_trig():void
		{
			cos_pitch_x = Math.cos(radiansx100(ahrs.pitch_sensor));
			cos_roll_x 	= Math.cos(radiansx100(ahrs.roll_sensor));
			sin_yaw_y 	= Math.sin(radiansx100(9000 - ahrs.yaw_sensor));	// 1y = north
			cos_yaw_x 	= Math.cos(radiansx100(9000 - ahrs.yaw_sensor));	// 0x = north

			//flat:
			// 0  	= cos_yaw:  0.00, sin_yaw:  1.00,
			// 90 	= cos_yaw:  1.00, sin_yaw:  0.00,
			// 180 	= cos_yaw:  0.00, sin_yaw: -1.00,
			// 270 	= cos_yaw: -1.00, sin_yaw:  0.00,
		}

		// updated at 10hz
		public function update_altitude():void
		{
			// read barometer
			baro_alt 				= baro.read();

			if(g.inertia_checkbox.getSelected()){
				//baro_rate			= (accels_position.z - old_baro_alt) * 10;
				//old_baro_alt		= accels_position.z;
				baro_rate			= accels_velocity.z;

			}else{
				// calc the vertical accel rate
				var temp:Number		= (baro_alt - old_baro_alt) * 10;
				baro_rate 			= (temp + baro_rate) >> 1;
				baro_rate			= constrain(baro_rate, -300, 300);
				old_baro_alt		= baro_alt;
			}

			//current_loc.alt 		= baro_alt;
			//climb_rate	 			= (current_loc.alt - old_altitude) * 10;
			//old_altitude 			= current_loc.alt;

			if(g.sonar_enabled){
				// filter out offset
				var scale:Number = 0;

				// calc rate of change for Sonar
				// calc the vertical accel rate
				// positive = going up.
				sonar_rate 		= (sonar_alt - old_sonar_alt) * 10;
				sonar_rate		= constrain(sonar_rate, -150, 150);
				old_sonar_alt 	= sonar_alt;

				if(baro_alt < 800){
					scale = (sonar_alt - 400) / 200.0;
					scale = constrain(scale, 0.0, 1.0);
					// solve for a blended altitude
					current_loc.alt = (sonar_alt * (1.0 - scale)) + (baro_alt * scale) + home.alt;

					// solve for a blended climb_rate
					climb_rate_actual = (sonar_rate * (1.0 - scale)) + baro_rate * scale;

				}else{
					// we must be higher than sonar (>800), don't get tricked by bad sonar reads
					current_loc.alt = baro_alt;
					// dont blend, go straight baro
					climb_rate_actual 	= baro_rate;
				}

			}else{
				// NO Sonar case
				current_loc.alt 	= baro_alt;
				climb_rate_actual 	= baro_rate;
			}

			// cosmetic
			current_loc.alt = Math.floor(current_loc.alt);

			// update the target altitude
			next_WP.alt = get_new_altitude();

			// get an average climb_rate for throttle cruise calc
			climb_rate_avg = (climb_rate_avg * 7 + climb_rate_actual) / 8;

			// calc error
			climb_rate_error = (climb_rate_actual - climb_rate) / 5;

			if(g.inertia_checkbox.getSelected())
				z_error_correction();
		}

		public function update_altitude_est():void
		{
			if(alt_sensor_flag){
				update_altitude();
				alt_sensor_flag = false;
				if(g.CTUN_checkbox.getSelected())
					Log_Write_Control_Tuning();

			}else{
				// simple dithering of climb rate
				climb_rate += climb_rate_error;
				current_loc.alt += (climb_rate / 50);
			}
		}

		//#define THROTTLE_ADJUST 225
		public function adjust_altitude():void
		{
			if(g.rc_3.control_in <= (g.throttle_min + THROTTLE_ADJUST)){
				// we remove 0 to 100 PWM from hover
				manual_boost = (g.rc_3.control_in - g.throttle_min) - THROTTLE_ADJUST;
				manual_boost = Math.max(-THROTTLE_ADJUST, manual_boost);

			}else if  (g.rc_3.control_in >= (g.throttle_max - THROTTLE_ADJUST)){
				// we add 0 to 100 PWM to hover
				manual_boost = g.rc_3.control_in - (g.throttle_max - THROTTLE_ADJUST);
				manual_boost = Math.min(THROTTLE_ADJUST, manual_boost);

			}else {
				manual_boost = 0;
			}
		}

		// Outputs Nav_Pitch and Nav_Roll
		public function update_nav_wp()
		{
			if(wp_control == LOITER_MODE){

				// calc error to target
				calc_location_error(next_WP);

				// use error as the desired rate towards the target
				calc_loiter(long_error, lat_error);

				// rotate pitch and roll to the copter frame of reference
				//calc_loiter_pitch_roll();

			}else if(wp_control == CIRCLE_MODE){

				// check if we have missed the WP
				var loiter_delta:int = (target_bearing - old_target_bearing)/100;

				// reset the old value
				old_target_bearing = target_bearing;

				// wrap values
				if (loiter_delta > 180) loiter_delta -= 360;
				if (loiter_delta < -180) loiter_delta += 360;

				// sum the angle around the WP
				loiter_sum += loiter_delta;

				// create a virtual waypoint that circles the next_WP
				// Count the degrees we have circulated the WP
				//int circle_angle = wrap_360(target_bearing + 3000 + 18000) / 100;

				circle_angle += (circle_rate * dTnav);
				//1° = 0.0174532925 radians

				// wrap
				if (circle_angle > 6.28318531)
					circle_angle -= 6.28318531;

				next_WP.lng = circle_WP.lng + (g.loiter_radius * 100 * Math.cos(1.57 - circle_angle) * scaleLongUp);
				next_WP.lat = circle_WP.lat + (g.loiter_radius * 100 * Math.sin(1.57 - circle_angle));

				// use error as the desired rate towards the target
				// nav_lon, nav_lat is calculated

				if(wp_distance > 400){
					calc_nav_rate(get_desired_speed(g.waypoint_speed_max, true));
				}else{
					// calc the lat and long error to the target
					calc_location_error(next_WP);

					calc_loiter(long_error, lat_error);
				}

				//CIRCLE: angle:29, dist:0, lat:400, lon:242

				// rotate pitch and roll to the copter frame of reference
				//calc_loiter_pitch_roll();

				// debug
				//int angleTest = degrees(circle_angle);
				//int nroll = nav_roll;
				//int npitch = nav_pitch;
				//Serial.printf("CIRCLE: angle:%d, dist:%d, X:%d, Y:%d, P:%d, R:%d  \n", angleTest, (int)wp_distance , (int)long_error, (int)lat_error, npitch, nroll);

			}else if(wp_control == WP_MODE){
				// calc error to target
				calc_location_error(next_WP);

				desired_speed = get_desired_speed(g.waypoint_speed_max, slow_wp);
				// use error as the desired rate towards the target
				calc_nav_rate(desired_speed);

				// rotate pitch and roll to the copter frame of reference
				//calc_loiter_pitch_roll();

				// XXX Finish and Sync
				limit_pitch_and_roll(altitude_error);


			}else if(wp_control == TOY_MODE){ // THOR added to navigate to Virtual WP
				calc_nav_rate(toy_speed);

			}else if(wp_control == NO_NAV_MODE){
				// clear out our nav so we can do things like land straight down
				// or change Loiter position

				// We bring copy over our Iterms for wind control, but we don't navigate
				nav_lon	= g.pid_loiter_rate_lon.get_integrator();
				nav_lat = g.pid_loiter_rate_lon.get_integrator();

				nav_lon			= constrain(nav_lon, -2000, 2000);			// 20°
				nav_lat			= constrain(nav_lat, -2000, 2000); 			// 20\u00b0

				// rotate pitch and roll to the copter frame of reference
				//calc_loiter_pitch_roll();
			}
		}

		public function update_auto_yaw():void
		{
			if(wp_control == CIRCLE_MODE){
				//trace("CIRCLE mode")
				auto_yaw = get_bearing(current_loc, circle_WP);

			}else if(wp_control == LOITER_MODE){
				// just hold nav_yaw

			}else if(yaw_tracking == MAV_ROI_LOCATION){
				auto_yaw = get_bearing(current_loc, target_WP);

			}else if(yaw_tracking == MAV_ROI_WPNEXT){
				// Point towards next WP
				auto_yaw = target_bearing;
			}
		}


		// -----------------------------------------------------------------------------------
		// Attitude
		//------------------------------------------------------------------------------------
		public function get_stabilize_roll(target_angle:Number):Number
		{
			var angle_error		:Number = 0;
			var rate			:Number = 0;
			var target_rate		:Number = 0;
			var iterm			:Number = 0;

			angle_error 		= wrap_180(target_angle - ahrs.roll_sensor);

			// convert to desired Rate:
			p_stab 				= g.pi_stabilize_roll.get_p(angle_error);


			if(Math.abs(ahrs.roll_sensor) < 500){
				angle_error 		= constrain(angle_error, -500, 500);
				i_stab 				= g.pi_stabilize_roll.get_i(angle_error, G_Dt);
			}else{
				i_stab 				= g.pi_stabilize_roll.get_integrator();
			}
			return get_rate_roll(p_stab) + i_stab;
		}

		public function get_stabilize_pitch(target_angle:Number):Number
		{
			var target_rate		:Number = 0;
			var i_stab			:Number = 0;

			// angle error
			target_angle 		= wrap_180(target_angle - ahrs.pitch_sensor);
			//trace(target_angle, ahrs.pitch_sensor);

			// convert to desired Rate:
			target_rate 		= g.pi_stabilize_pitch.get_p(target_angle);

			if(Math.abs(ahrs.roll_sensor) < 500){
				target_angle 		= constrain(target_angle, -500, 500);
				i_stab 				= g.pi_stabilize_pitch.get_i(target_angle, G_Dt);
			}else{
				i_stab 				= g.pi_stabilize_pitch.get_integrator();
			}
			return get_rate_pitch(target_rate) + i_stab;
		}

		public function get_stabilize_yaw(target_angle:Number):Number
		{
			var target_rate		:Number = 0;
			var i_term			:Number = 0;
			var angle_error		:Number = 0;
			var output			:Number = 0;

			// angle error
			angle_error	 	= wrap_180(target_angle - ahrs.yaw_sensor);

			// limit the error we're feeding to the PID
			angle_error 		= constrain(angle_error, -4000, 4000);

			// convert angle error to desired Rate:
			target_rate = g.pi_stabilize_yaw.get_p(angle_error);
			i_term = g.pi_stabilize_yaw.get_i(angle_error, G_Dt);

			// do not use rate controllers for helicotpers with external gyros
			output = get_rate_yaw(target_rate) + i_term;

			// ensure output does not go beyond barries of what an int16_t can hold
			return constrain(output,-32000,32000);
		}


		public function get_acro_roll(target_rate:int):int
		{
			target_rate = target_rate * g.acro_p;
			return get_rate_roll(target_rate);
		}

		public function get_acro_pitch(target_rate:int):int
		{
			target_rate = target_rate * g.acro_p;
			return get_rate_pitch(target_rate);
		}

		public function get_acro_yaw(target_rate:int):int
		{
			// 31500 for 7 * 4500
			target_rate = g.pi_stabilize_yaw.get_p(target_rate);
			return get_rate_yaw(target_rate);
		}


		public function get_rate_roll(target_rate:Number):Number
		{
			var current_rate	:Number = 0;
			var rate_d			:Number = 0;
			var output			:Number = 0;

			// get current rate
			current_rate 	= (ahrs.omega.x * DEGX100);

			// calculate and filter the acceleration
			rate_d 			= -roll_rate_d_filter.apply(current_rate - roll_last_rate);

			// store rate for next iteration
			roll_last_rate 	= current_rate;

			// call pid controller
			roll_rate_error	= target_rate - current_rate;

			p_stab_rate 	= g.pid_rate_roll.get_p(roll_rate_error);
			i_stab_rate		= g.pid_rate_roll.get_i(roll_rate_error, G_Dt);
			d_stab_rate		= g.pid_rate_roll.get_d(roll_rate_error, G_Dt);
			output			= p_stab_rate + i_stab_rate + d_stab_rate;

			//trace(ahrs.roll_sensor, rate_d, current_rate);

			// Dampening output with D term
			rate_d_dampener = rate_d * roll_scale_d;
			rate_d_dampener = constrain(rate_d_dampener, -400, 400);
			output -= rate_d_dampener;

			// constrain output
			output = constrain(output, -5000, 5000);

			roll_output = output

			// output control
			return output;
		}


		public function get_rate_pitch(target_rate:Number):Number
		{
			var current_rate		:Number = 0;
			//roll_rate_error
			var rate_d				:Number = 0;
			var output				:Number = 0;
			var _rate_d_dampener	:Number = 0;

			// get current rate
			current_rate 	= (ahrs.omega.y * DEGX100);

			// calculate and filter the acceleration
			rate_d 			= pitch_rate_d_filter.apply(current_rate - pitch_last_rate);

			// store rate for next iteration
			pitch_last_rate 		= current_rate;

			// call pid controller
			pitch_rate_error = target_rate - current_rate;
			output			 = g.pid_rate_pitch.get_pid(pitch_rate_error, G_Dt);

			// Dampening output with D term
			_rate_d_dampener = rate_d * pitch_scale_d;
			_rate_d_dampener = constrain(_rate_d_dampener, -400, 400);
			output -= _rate_d_dampener;

			// constrain output
			output = constrain(output, -5000, 5000);

			// output control
			return output;
		}


		public function get_rate_yaw(target_rate:Number):Number
		{
			var rate_error		:Number = 0;
			var output			:Number = 0;
			var yaw_limit		:Number = 0;

			// rate control
			rate_error	 	= target_rate - (ahrs.omega.z * DEGX100);
			//trace(target_rate, " - ", (ahrs.omega.z * DEGX100)," = ", rate_error);

			// separately calculate p, i, d values for logging
			output = g.pid_rate_yaw.get_pid(rate_error, G_Dt);
			yaw_limit = 1900 + Math.abs(g.rc_4.control_in);
			//trace("output:", output, "yaw lim:", yaw_limit);

			// constrain output
			yaw_output = constrain(output, -yaw_limit, yaw_limit);

			// constrain output
			return yaw_output;
		}

		// call at 10hz
		public function get_nav_throttle(z_error:Number):Number
		{
			// convert to desired Rate:
			z_target_speed 		= g.pi_alt_hold.get_p(z_error);			// calculate desired speed from lon error
			z_target_speed		= constrain(z_target_speed, -250, 250);

			// limit error to prevent I term wind up
			z_error				= constrain(z_error, -400, 400);

			// compensates throttle setpoint error for hovering
			i_hold				= g.pi_alt_hold.get_i(z_error, m_dt);			// calculate desired speed from lon error

			return get_throttle_rate(z_target_speed) + i_hold;
		}

		// call at 10hz
		public function get_throttle_rate(_z_target_speed:Number):Number
		{
			var output:Number = 0;

			// calculate rate error
			if(g.inertia_checkbox.getSelected()){
				z_rate_error		= _z_target_speed - accels_velocity.z;			// calc the speed error
			}else{
				z_rate_error		= _z_target_speed - climb_rate;		// calc the speed error
			}

			p_alt_rate			= g.pid_throttle.get_p(z_rate_error);
			i_alt_rate			= g.pid_throttle.get_i(z_rate_error, m_dt);
			d_alt_rate			= g.pid_throttle.get_d(z_rate_error, m_dt);
			d_alt_rate			= constrain(d_alt_rate, -2000, 2000);

			var tmp:Number  = (_z_target_speed * _z_target_speed * g.alt_comp) / 10000;
			tmp = Math.round(tmp);

			//100 * 100 * .5 / 10000
			if(_z_target_speed < 0) tmp = -tmp;
			output			= constrain(tmp, -180, 180);

			if (Math.abs(climb_rate_avg) < 20)
				d_alt_rate = 0;

			output	+= p_alt_rate + i_alt_rate + d_alt_rate;

			// limit the rate
			output	= constrain(output, -80, 120);

			return output;
		}

		// Keeps old data out of our calculation / logs
		public function reset_nav_params():void
		{
			nav_throttle 			= 0;

			// always start Circle mode at same angle
			circle_angle			= 0;

			// We must be heading to a new WP, so XTrack must be 0
			crosstrack_error 		= 0;

			// Will be set by new command
			target_bearing 			= 0;

			// Will be set by new command
			wp_distance 			= 0;

			// Will be set by new command, used by loiter
			long_error 				= 0;
			lat_error  				= 0;

			auto_roll 				= 0;
			auto_pitch 				= 0;

			// Will be set by new command, used by loiter
			next_WP.alt				= 0;

			// We want to by default pass WPs
			slow_wp = false;
		}

		/*
		  reset all I integrators
		 */
		public function reset_I_all():void
		{
			reset_rate_I();
			reset_stability_I();
			reset_wind_I();
			reset_throttle_I();
			//reset_optflow_I()

			// This is the only place we reset Yaw
			g.pi_stabilize_yaw.reset_I();
		}

		public function reset_rate_I():void
		{
			g.pid_rate_roll.reset_I();
			g.pid_rate_pitch.reset_I();
			g.pid_rate_yaw.reset_I();
		}

		static public function reset_optflow_I():void
		{
			/*g.pid_optflow_roll.reset_I();
			g.pid_optflow_pitch.reset_I();
			of_roll = 0;
			of_pitch = 0;*/
		}


		public function reset_wind_I():void
		{
			// Wind Compensation
			// this i is not currently being used, but we reset it anyway
			// because someone may modify it and not realize it, causing a bug
			g.pi_loiter_lat.reset_I();
			g.pi_loiter_lon.reset_I();

			g.pid_loiter_rate_lat.reset_I();
			g.pid_loiter_rate_lon.reset_I();

			g.pid_nav_lat.reset_I();
			g.pid_nav_lon.reset_I();
		}

		public function reset_throttle_I():void
		{
			// For Altitude Hold
			g.pi_alt_hold.reset_I();
			g.pid_throttle.reset_I();
		}

		public function reset_stability_I():void
		{
			// Used to balance a quad
			// This only needs to be reset during Auto-leveling in flight
			g.pi_stabilize_roll.reset_I();
			g.pi_stabilize_pitch.reset_I();
		}


		// THOR
		// The function call for managing the flight mode Toy
		public function roll_pitch_toy():void
		{
			var manual_control:Boolean = false;

			if(g.rc_2.control_in != 0){
				// If we pitch forward or back, resume manually control
				manual_control  = true;
			}

			// Yaw control - Yaw is always available, and will NOT exit the
			// user from Loiter mode
			var yaw_rate:int = g.rc_1.control_in / g.toy_yaw_rate;

			if(g.rc_1.control_in != 0){
				g.rc_4.servo_out = get_acro_yaw(yaw_rate/2);
				yaw_stopped = false;
				yaw_timer = 150;
			}else if (!yaw_stopped){
				g.rc_4.servo_out = get_acro_yaw(0);
				yaw_timer--;
				if(yaw_timer == 0){
					yaw_stopped = true;
					nav_yaw = ahrs.yaw_sensor;
				}
			}else{
				nav_yaw = get_nav_yaw_offset(yaw_rate, g.rc_3.control_in);
				g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
			}


			// We manually set our modes based on the state of Toy mode:
			// Handle throttle manually
			if(toy_alt_hold){
				throttle_mode 	= THROTTLE_HOLD;
			}else{
				throttle_mode 	= THROTTLE_MANUAL;
			}

			if(manual_control){
				// user is in control: reset count-up timer
				toy_input_timer = 0;

				// roll_rate is the outcome of the linear equation or lookup table
				// based on speed and Yaw rate
				var roll_rate:int;


				// Dont try to navigate or integrate a nav error
				wp_control 		= NO_NAV_MODE;

				//if(g.test == false){
					// yaw_rate = roll angle
					// Linear equation for Yaw:Speed to Roll
					// default is 1000, lower for more roll action
					//roll_rate = (g_gps.ground_speed / 500) * yaw_rate;
					// limit roll rate to 15, 30, or 45 deg per second.
					//roll_rate = constrain(roll_rate, -(4500 / g.toy_yaw_rate), (4500 / g.toy_yaw_rate));
					roll_rate = (g.rc_2.control_in * (yaw_rate/100)) /40;
					roll_rate = constrain(roll_rate, -2500, 2500);
					trace("roll_rate", roll_rate);

				/*}else{
					// Lookup value
					var xx:int = g_gps.ground_speed / 200;
					var yy:int = Math.abs(yaw_rate / 500);

					xx = constrain(xx, 0, 3);
					yy = constrain(yy, 0, 8);

					roll_rate = toy_lookup[yy * 4 + xx];

					if(yaw_rate == 0)
						roll_rate = 0;
					else if(yaw_rate < 0)
						roll_rate = -roll_rate;

					roll_rate = constrain(roll_rate, -(4500 / g.toy_yaw_rate), (4500 / g.toy_yaw_rate));

				}*/

				// Output the attitude
				g.rc_1.servo_out = get_stabilize_roll(roll_rate);
				g.rc_2.servo_out = get_stabilize_pitch(g.rc_2.control_in);

			}else{
				// No user input
				// Count-up to decision tp Loiter
				toy_input_timer++;

				if ((wp_control != LOITER_MODE) && ((g_gps.ground_speed < 150) || (toy_input_timer == TOY_DELAY))){
					//no user input, lets enter loiter
					trace("Enter Toy Loiter", g_gps.ground_speed);

					// resets so we don't overflow the timer
					toy_input_timer = TOY_DELAY;

					// clear our I terms for Nav or we will carry over old values
					reset_wind_I();
					reset_nav_params();

					// loiter
					wp_control 	= LOITER_MODE;

					// we are in an alt hold throttle with manual override
					//throttle_mode 	= THROTTLE_HOLD;

					set_next_WP(current_loc);
				}

				if(wp_control == LOITER_MODE){
					// prevent timer overflow
					toy_input_timer = TOY_DELAY;

					//trace("loiter control" ,g_gps.ground_speed);
					g.rc_1.servo_out 	= get_stabilize_roll(auto_roll);
					g.rc_2.servo_out 	= get_stabilize_pitch(auto_pitch);
				}else{
					//trace("Coast" ,g_gps.ground_speed);
					// Coast
					g.rc_1.servo_out 	= get_stabilize_roll(0);
					g.rc_2.servo_out 	= get_stabilize_pitch(0);
				}
			}
		}


		// THOR
		// The function call for managing the flight mode Toy
		public function roll_pitch_toy1():void
		{
			var manual_control:Boolean = false;

			if(g.rc_2.control_in != 0){ // pitch
				manual_control  = true;

			}else if(g.rc_1.control_in != 0){ // Roll/Yaw combo
				// we have some user input
				if(wp_control == TOY_MODE){
					// we are heading to Virtual WP
					manual_control  = true;
				}else{
					// we are in manual control
					manual_control  = false;
				}
			}

			// Yaw control - Yaw is always available, and will NOT exit the
			// user from Loiter mode
			var yaw_rate:int = g.rc_1.control_in / g.toy_yaw_rate;
			nav_yaw += yaw_rate / 100;
			nav_yaw = wrap_360(nav_yaw);
			g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);

			if(manual_control){
				// user is in control: reset count-up timer
				toy_input_timer = 0;

				// roll_rate is the outcome of the linear equation or lookup table
				// based on speed and Yaw rate
				var roll_rate:int;

				// We manually set out modes based on the state of Toy mode:
				// Handle throttle manually
				throttle_mode 	= THROTTLE_MANUAL;
				// Dont try to navigate or integrate a nav error
				wp_control 		= NO_NAV_MODE;

				if(g.test == false){
				// yaw_rate = roll angle
				// Linear equation for Yaw:Speed to Roll
				// default is 1000, lower for more roll action
				roll_rate = (g_gps.ground_speed / 1000) * yaw_rate;
				// limit roll rate to 15, 30, or 45 deg per second.
				roll_rate = constrain(roll_rate, -(4500 / g.toy_yaw_rate), (4500 / g.toy_yaw_rate));

				}else{

				// Lookup value
				var xx:int = g_gps.ground_speed / 200;
				var yy:int = Math.abs(yaw_rate / 500);

				xx = constrain(xx, 0, 3);
				yy = constrain(yy, 0, 8);

				roll_rate = toy_lookup[yy * 4 + xx];

				if(yaw_rate == 0)
					roll_rate = 0;
				else if(yaw_rate < 0)
					roll_rate = -roll_rate;

				roll_rate = constrain(roll_rate, -(4500 / g.toy_yaw_rate), (4500 / g.toy_yaw_rate));

				}
				// Output the attitude
				g.rc_1.servo_out = get_stabilize_roll(roll_rate);
				g.rc_2.servo_out = get_stabilize_pitch(g.rc_2.control_in);

			}else{
				// No user input
				// Count-up to decision - Loiter or Virtual WP
				toy_input_timer++;

				if (toy_input_timer == TOY_DELAY){

					// clear our I terms for Nav or we will carry over old values
					reset_wind_I();

					if (g_gps.ground_speed < 200) {
						// loiter
						wp_control = LOITER_MODE;
						set_next_WP(current_loc);

					}else{
						// hold velocity and
						// calc a new WP 10000cm ahead (Approximate)
						var tmp:Location = new Location();
						tmp.lng = current_loc.lng + (10000 * cos_yaw_x);  	// X or East/West
						tmp.lat = current_loc.lat + (10000 * sin_yaw_y);	// Y or North/South
						tmp.alt = current_loc.alt;
						set_next_WP(tmp);

						// A special navigation mode for Toy mode that maintains the entry speed
						wp_control 	= TOY_MODE;
						// Save our speed as we entered the mode
						toy_speed 	= g_gps.ground_speed;
					}

					// Just level out until we hit 1.5s
					g.rc_1.servo_out 	= get_stabilize_roll(0);
					g.rc_2.servo_out 	= get_stabilize_pitch(0);

				}else if (toy_input_timer > TOY_DELAY){
					// we are in an alt hold throttle with manual override
					throttle_mode 	= THROTTLE_HOLD;
					// resets so we don't overflow the timer
					toy_input_timer = TOY_DELAY;

					// outputs the needed nav_control to maintain speed and direction
					g.rc_1.servo_out 	= get_stabilize_roll(auto_roll);
					g.rc_2.servo_out 	= get_stabilize_pitch(auto_pitch);

				}else{

					// outputs the needed nav_control to maintain speed and direction
					g.rc_1.servo_out 	= get_stabilize_roll(0);
					g.rc_2.servo_out 	= get_stabilize_pitch(0);
				}
			}
		}

		/*************************************************************
		throttle control
		****************************************************************/

		public function get_nav_yaw_offset(yaw_input:int, reset:int):Number
		{
			var _yaw:Number = 0;

			if(reset == 0){
				// we are on the ground
				return ahrs.yaw_sensor;

			}else{
				// re-define nav_yaw if we have stick input
				if(yaw_input != 0){
					// set nav_yaw + or - the current location
					_yaw = yaw_input + ahrs.yaw_sensor;
					// we need to wrap our value so we can be 0 to 360 (*100)
					return wrap_360(_yaw);
				} else{

					// no stick input, lets not change nav_yaw
					return nav_yaw;
				}
			}
		}

		public function get_angle_boost(value:Number):Number
		{
			var temp:Number = cos_pitch_x * cos_roll_x;
			temp = constrain(temp, .5, 1.0);
			return ((g.throttle_cruise + 80) / temp) - (g.throttle_cruise + 80);
		}

		// -----------------------------------------------------------------------------------
		// commands.pde
		//------------------------------------------------------------------------------------

		public function init_commands():void
		{
			g.command_index 		= NO_COMMAND;
			command_nav_index		= NO_COMMAND;
			command_cond_index		= NO_COMMAND;
			prev_nav_index 			= NO_COMMAND;
			command_cond_queue.id 	= NO_COMMAND;
			command_nav_queue.id 	= NO_COMMAND;

			// default Yaw tracking
			yaw_tracking 			= MAV_ROI_WPNEXT;
		}

		// Getters
		// -------
		public function get_cmd_with_index(i:int):Location
		{
			var temp:Location = new Location();

			// Find out proper location in memory by using the start_byte position + the index
			// --------------------------------------------------------------------------------
			if (i >= g.command_total) {
				// we do not have a valid command to load
				// return a WP with a "Blank" id
				temp.id = CMD_BLANK;

				// no reason to carry on
				return temp;

			}else{
				// we can load a command, we don't process it yet
				// read WP position

				temp = waypoints[i].clone();

			}

			if(temp.options & WP_OPTION_RELATIVE){
				// If were relative, just offset from home
				temp.lat	+=	home.lat;
				temp.lng	+=	home.lng;
			}

			return temp;
		}

		// Setters
		// -------
		public function set_cmd_with_index(temp:Location, i:int):void
		{

			i = constrain(i, 0, g.command_total);
			//Serial.printf("set_command: %d with id: %d\n", i, temp.id);
			//trace("set_command: "+i+" with id: "+ temp.id);
			//report_wp();

			// store home as 0 altitude!!!
			// Home is always a MAV_CMD_NAV_WAYPOINT (16)
			if (i == 0){
				temp.alt = 0;
				temp.id = MAV_CMD_NAV_WAYPOINT;
			}

			waypoints[i] = temp.clone();

			// Make sure our WP_total
			if(g.command_total < (i+1))
				g.command_total = i + 1;
		}

		public function get_RTL_alt():Number
		{
			if(g.RTL_altitude <= 0){
				return current_loc.alt;
			}else if (g.RTL_altitude < current_loc.alt){
				return current_loc.alt;
			}else{
				return g.RTL_altitude;
			}
		}

		public function set_next_WP(wp:Location):void
		{
			// copy the current WP into the OldWP slot
			// ---------------------------------------
			if (next_WP.lat == 0 || command_nav_index <= 1){
				prev_WP = current_loc.clone();
			}else{
				if (get_distance(current_loc, next_WP) < 500){
					prev_WP = next_WP.clone();
				}else{
					prev_WP = current_loc.clone();
				}
			}

			// Load the next_WP slot
			// ---------------------
			next_WP = wp.clone();

			print_wp(next_WP, g.command_index);

			// used to control and limit the rate of climb
			// -------------------------------------------
			// We don't set next WP below 1m
			next_WP.alt = Math.max(next_WP.alt, 100);

			// Save new altitude so we can track it for climb_rate
			set_new_altitude(next_WP.alt);

			// this is handy for the ground station
			// -----------------------------------
			wp_distance 		= get_distance(current_loc, next_WP);
			target_bearing 		= get_bearing(prev_WP, next_WP);

			// calc the location error:
			calc_location_error(next_WP);

			// to check if we have missed the WP
			// ---------------------------------
			original_target_bearing = target_bearing;

			// reset speed governer
			// --------------------
			waypoint_speed_gov = WAYPOINT_SPEED_MIN;
		}


		// run this at setup on the ground
		// -------------------------------
		public function init_home():void
		{
			home_is_set = true;
			home.id 	= MAV_CMD_NAV_WAYPOINT;
			home.lng 	= 0; //g_gps.longitude;				// Lon * 10**7
			home.lat 	= 0; //g_gps.latitude;				// Lat * 10**7
			home.alt 	= 0;							// Home is always 0

			// to point yaw towards home until we set it with Mavlink
			target_WP 	= home.clone();

			// Save Home to EEPROM
			// -------------------
			// no need to save this to EPROM
			set_cmd_with_index(home, 0);
			//print_wp(home, 0);

			// Save prev loc this makes the calcs look better before commands are loaded
			prev_WP = home.clone();

			// in case we RTL
			next_WP = home.clone();

			// Load home for a default guided_WP
			// -------------
			guided_WP = home.clone();
			guided_WP.alt += g.RTL_altitude;
		}



		/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

		/********************************************************************************/
		// Command Event Handlers
		/********************************************************************************/
		public function process_nav_command()
		{
			switch(command_nav_queue.id){

				case MAV_CMD_NAV_TAKEOFF:	// 22
					trace("do command takeoff")
					do_takeoff();
					break;

				case MAV_CMD_NAV_WAYPOINT:	// 16  Navigate to Waypoint
					//trace("do command nav WP")
					do_nav_wp();
					break;

				case MAV_CMD_NAV_LAND:	// 21 LAND to Waypoint
					trace("do command Land")
					yaw_mode 		= YAW_HOLD;
					do_land();
					break;

				case MAV_CMD_NAV_LOITER_UNLIM:	// 17 Loiter indefinitely
					trace("do command Loiter unlimited")
					do_loiter_unlimited();
					break;

				case MAV_CMD_NAV_LOITER_TURNS:	//18 Loiter N Times
					trace("do command Loiter n turns")
					do_loiter_turns();
					break;

				case MAV_CMD_NAV_LOITER_TIME:  // 19
					trace("do command Loiter time")
					do_loiter_time();
					break;

				case MAV_CMD_NAV_RETURN_TO_LAUNCH: //20
					trace("do command RTL")
					do_RTL();
					break;

				default:
					break;
			}

		}

		public function process_cond_command()
		{
			switch(command_cond_queue.id){

				case MAV_CMD_CONDITION_DELAY: // 112
					trace("do command delay")
					do_wait_delay();
					break;

				case MAV_CMD_CONDITION_DISTANCE: // 114
					trace("do command distance")
					do_within_distance();
					break;

				case MAV_CMD_CONDITION_CHANGE_ALT: // 113
					trace("do command change alt")
					do_change_alt();
					break;

				case MAV_CMD_CONDITION_YAW: // 115
					trace("do command change Yaw")
					do_yaw();
					break;

				default:
					break;
			}
		}

		public function process_now_command()
		{
			switch(command_cond_queue.id){

				case MAV_CMD_DO_JUMP:  // 177
					trace("do command Jump")
					do_jump();
					break;

				case MAV_CMD_DO_CHANGE_SPEED: // 178
					trace("do command change speed")
					do_change_speed();
					break;

				case MAV_CMD_DO_SET_HOME: // 179
					trace("do command set home")
					do_set_home();
					break;

				case MAV_CMD_DO_SET_SERVO: // 183
					trace("do command set servo")
					do_set_servo();
					break;

				case MAV_CMD_DO_SET_RELAY: // 181
					trace("do command set relay")
					do_set_relay();
					break;

				case MAV_CMD_DO_REPEAT_SERVO: // 184
					trace("do command repeat servo")
					do_repeat_servo();
					break;

				case MAV_CMD_DO_REPEAT_RELAY: // 182
					trace("do command repeat relay")
					do_repeat_relay();
					break;

				case MAV_CMD_DO_SET_ROI: // 201
					trace("do command set ROI")
					do_target_yaw();
			}
		}


		/********************************************************************************/
		// Verify command Handlers
		/********************************************************************************/

		public function verify_must()
		{
			switch(command_nav_queue.id) {

				case MAV_CMD_NAV_TAKEOFF:
					return verify_takeoff();
					break;

				case MAV_CMD_NAV_LAND:
					if(g.sonar_enabled == true){
						return verify_land_sonar();
					}else{
						return verify_land_baro();
					}
					break;

				case MAV_CMD_NAV_WAYPOINT:
					return verify_nav_wp();
					break;

				case MAV_CMD_NAV_LOITER_UNLIM:
					return verify_loiter_unlimited();
					break;

				case MAV_CMD_NAV_LOITER_TURNS:
					return verify_loiter_turns();
					break;

				case MAV_CMD_NAV_LOITER_TIME:
					return verify_loiter_time();
					break;

				case MAV_CMD_NAV_RETURN_TO_LAUNCH:
					return verify_RTL();
					break;

				default:
					//gcs_send_text_P(SEVERITY_HIGH,PSTR("<verify_must: default> No current Must commands"));
					return false;
					break;
			}
		}

		public function verify_may():Boolean
		{
			switch(command_cond_queue.id) {

				case MAV_CMD_CONDITION_DELAY:
					return verify_wait_delay();
					break;

				case MAV_CMD_CONDITION_DISTANCE:
					return verify_within_distance();
					break;

				case MAV_CMD_CONDITION_CHANGE_ALT:
					return verify_change_alt();
					break;

				case MAV_CMD_CONDITION_YAW:
					return verify_yaw();
					break;

				default:
					//gcs_send_text_P(SEVERITY_HIGH,PSTR("<verify_must: default> No current May commands"));
					return false;
					break;
			}
		}

		/********************************************************************************/
		//
		/********************************************************************************/

		public function do_RTL():void
		{
			// TODO: Altitude option from mission planner
			var temp:Location = home.clone();
			temp.alt		= get_RTL_alt();

			//so we know where we are navigating from
			// --------------------------------------
			next_WP 		= current_loc.clone();

			// Loads WP from Memory
			// --------------------
			set_next_WP(temp);


			// We want to come home and stop on a dime
			slow_wp = true;

			// output control mode to the ground station
			// -----------------------------------------
			//gcs_send_message(MSG_HEARTBEAT);
		}

		/********************************************************************************/
		//	Nav (Must) commands
		/********************************************************************************/

		public function do_takeoff():void
		{
			wp_control = LOITER_MODE;

			// Start with current location
			var temp:Location = current_loc.clone();

			temp.alt = command_nav_queue.alt;

			// prevent flips
			reset_I_all();

			// Set our waypoint
			set_next_WP(temp);
		}

		public function do_nav_wp():void
		{
			trace("do_nav_wp", control_mode);
			wp_control = WP_MODE;

			set_next_WP(command_nav_queue);

			// this is our bitmask to verify we have met all conditions to move on
			wp_verify_byte 	= 0;

			// this will be used to remember the time in millis after we reach or pass the WP.
			loiter_time 	= 0;

			// this is the delay, stored in seconds and expanded to millis
			loiter_time_max = command_nav_queue.p1 * 1000;

			// if we don't require an altitude minimum, we save this flag as passed (1)
			if((next_WP.options & MASK_OPTIONS_RELATIVE_ALT) == 0){
				// we don't need to worry about it
				wp_verify_byte |= NAV_ALTITUDE;
			}
		}

		public function do_land():void
		{
			wp_control = LOITER_MODE;

			// just to make sure
			land_complete		= false;

			// landing boost lowers the main throttle to mimmick
			// the effect of a user's hand
			landing_boost 		= 0;

			// A counter that goes up if our climb rate stalls out.
			ground_detector 	= 0;

			// hold at our current location
			set_next_WP(current_loc);

			// Set a new target altitude low, incase we are landing on a hill!
			set_new_altitude(0);
		}

		public function do_loiter_unlimited():void
		{
			//Serial.println("dloi ");
			if(command_nav_queue.lat == 0){
				wp_control = LOITER_MODE;
				set_next_WP(current_loc);
			}else{
				set_next_WP(command_nav_queue);
				wp_control = WP_MODE;
			}
		}

		public function do_loiter_turns():void
		{
			wp_control = CIRCLE_MODE;

			if(command_nav_queue.lat == 0){
				// allow user to specify just the altitude
				if(command_nav_queue.alt > 0){
					current_loc.alt = command_nav_queue.alt;
				}
				set_next_WP(current_loc);
			}else{
				set_next_WP(command_nav_queue);
			}

			circle_WP		= next_WP.clone();

			loiter_total = command_nav_queue.p1 * 360;
			loiter_sum	 = 0;
			old_target_bearing = target_bearing;

			circle_angle = target_bearing + 18000;
			circle_angle = wrap_360(circle_angle);
			circle_angle *= RADX100;
		}

		public function do_loiter_time():void
		{
			if(command_nav_queue.lat == 0){
				wp_control 		= LOITER_MODE;
				loiter_time 	= millis();
				set_next_WP(current_loc);
			}else{
				wp_control 		= WP_MODE;
				set_next_WP(command_nav_queue);
			}

			loiter_time_max = command_nav_queue.p1 * 1000; // units are (seconds)

			trace("loiter_time_max = ", loiter_time_max);
		}

		/********************************************************************************/
		//	Verify Nav (Must) commands
		/********************************************************************************/

		public function verify_takeoff():Boolean
		{
			// wait until we are ready!
			if(g.rc_3.control_in == 0){
				return false;
			}
			// are we above our target altitude?
			//return (current_loc.alt > next_WP.alt);
			return (current_loc.alt > target_altitude);
		}

		// called at 10hz
		public function verify_land_sonar():Boolean
		{
			//static float icount = 1;

			if(current_loc.alt > 300){
				wp_control = LOITER_MODE;
				//icount = 1;
				ground_detector = 0;
			}else{
				// begin to pull down on the throttle
				landing_boost++;
				landing_boost = Math.min(landing_boost, 40);
			}

			if(current_loc.alt < 200 ){
				wp_control 	= NO_NAV_MODE;
			}

			if(current_loc.alt < 150 ){
				//rapid throttle reduction
				//int16_t lb  = (1.75 * icount * icount) - (7.2 * icount);
				//icount++;
				//lb =  constrain(lb, 0, 180);
				//landing_boost += lb;
				//Serial.printf("%0.0f, %d, %d, %d\n", icount, current_loc.alt, landing_boost, lb);

				// if we are low or don't seem to be decending much, increment ground detector
				if(current_loc.alt < 40 || Math.abs(climb_rate_avg) < 30) {
					landing_boost++;  // reduce the throttle at twice the normal rate
					if(ground_detector < 30) {
						ground_detector++;
					}else if (ground_detector == 30){
						trace("land_complete= ",land_complete);
						land_complete = true;
						if(g.rc_3.control_in == 0){
							ground_detector++;
							init_disarm_motors();
						}
						return true;
					}
				}
			}
			return false;
		}


		public function verify_land_baro():Boolean
		{
			if(current_loc.alt > 300){
				wp_control = LOITER_MODE;
				ground_detector = 0;
			}else{
				// begin to pull down on the throttle
				landing_boost++;
				landing_boost = Math.min(landing_boost, 40);
			}

			if(current_loc.alt < 200 ){
				wp_control 	= NO_NAV_MODE;
			}

			if(current_loc.alt < 150 ){
				if(Math.abs(climb_rate_avg) < 20) {
					//trace("climb_rate_avg",climb_rate_avg);
					landing_boost++;
					if(ground_detector < 30) {
						ground_detector++;
					}else if (ground_detector == 30){
						land_complete = true;
						if(g.rc_3.control_in == 0){
							ground_detector++;
							init_disarm_motors();
						}
						return true;
					}
				}
			}
			return false;
		}

		public function verify_nav_wp():Boolean
		{
			// Altitude checking
			if(next_WP.options & MASK_OPTIONS_RELATIVE_ALT){
				// we desire a certain minimum altitude
				//if (current_loc.alt > next_WP.alt){
				if (current_loc.alt > target_altitude){

					// we have reached that altitude
					wp_verify_byte |= NAV_ALTITUDE;
				}
			}

			// Did we pass the WP?	// Distance checking
			if((wp_distance <= (g.waypoint_radius * 100)) || check_missed_wp()){

				// if we have a distance calc error, wp_distance may be less than 0
				if(wp_distance > 0){
					wp_verify_byte |= NAV_LOCATION;

					if(loiter_time == 0){
						loiter_time = millis();
						trace("Loiter for x seconds:", loiter_time_max);
					}
				}
			}

			// Hold at Waypoint checking, we cant move on until this is OK
			if(wp_verify_byte & NAV_LOCATION){
				// we have reached our goal

				// loiter at the WP
				wp_control 	= LOITER_MODE;

				if ((millis() - loiter_time) > loiter_time_max) {
					wp_verify_byte |= NAV_DELAY;
					//gcs_send_text_P(SEVERITY_LOW,PSTR("verify_must: LOITER time complete"));
					//Serial.println("vlt done");
				}
			}

			if(wp_verify_byte >= 7){
			//if(wp_verify_byte & NAV_LOCATION){
				//trace("Reached Command ", command_nav_index)
				wp_verify_byte = 0;
				return true;
			}else{
				return false;
			}
		}

		public function verify_loiter_unlimited()
		{
			if(wp_control == WP_MODE &&  wp_distance <= (g.waypoint_radius * 100)){
				// switch to position hold
				wp_control 	= LOITER_MODE;
			}
			return false;
		}

		public function verify_loiter_time():Boolean
		{
			if(wp_control == LOITER_MODE){
				if ((millis() - loiter_time) > loiter_time_max) {
					return true;
				}
			}
			if(wp_control == WP_MODE &&  wp_distance <= (g.waypoint_radius * 100)){
				// reset our loiter time
				loiter_time = millis();
				// switch to position hold
				wp_control 	= LOITER_MODE;
			}
			return false;
		}

		public function verify_loiter_turns():Boolean
		{
			//Serial.printf("loiter_sum: %d \n", loiter_sum);
			// have we rotated around the center enough times?
			// -----------------------------------------------
			if(Math.abs(loiter_sum) > loiter_total) {
				loiter_total 	= 0;
				loiter_sum		= 0;
				//gcs_send_text_P(SEVERITY_LOW,PSTR("verify_must: LOITER orbits complete"));
				// clear the command queue;
				return true;
			}
			return false;
		}

		public function verify_RTL():Boolean
		{
			wp_control 	= WP_MODE;

			// Did we pass the WP?	// Distance checking
			if((wp_distance <= (g.waypoint_radius * 100)) || check_missed_wp()){
				wp_control 	= LOITER_MODE;

				//gcs_send_text_P(SEVERITY_LOW,PSTR("Reached home"));
				return true;
			}else{
				return false;
			}
		}

		/********************************************************************************/
		//	Condition (May) commands
		/********************************************************************************/

		public function do_wait_delay():void
		{
			//Serial.print("dwd ");
			condition_start = millis();
			condition_value	= command_cond_queue.lat * 1000; // convert to milliseconds
			//Serial.println(condition_value,DEC);
		}

		public function do_change_alt():void
		{
			var temp:Location	= next_WP;
			condition_start = current_loc.alt;
			//condition_value	= command_cond_queue.alt;
			temp.alt		= command_cond_queue.alt;
			set_next_WP(temp);
		}

		public function do_within_distance():void
		{
			condition_value	 = command_cond_queue.lat * 100;
		}

		public function do_yaw():void
		{
			//Serial.println("dyaw ");
			yaw_tracking = MAV_ROI_NONE;

			// target angle in degrees
			command_yaw_start		= nav_yaw; // current position
			command_yaw_start_time	= millis();

			command_yaw_dir			= command_cond_queue.p1;			// 1 = clockwise,	 0 = counterclockwise
			//					  		command_cond_queue.alt * 100;   // end Yaw angle or delta angle
			command_yaw_speed		= command_cond_queue.lat * 100; 	// ms * 100
			command_yaw_relative	= command_cond_queue.lng;			// 1 = Relative,	 0 = Absolute

			// example:
			// 115, 0, 1, 720, 45, 1 // clockwise, 720°, 45°/s, relative to current

			// if unspecified go 30\u00b0 a second
			if(command_yaw_speed == 0)
				command_yaw_speed = 3000;

			// if unspecified go counterclockwise
			if(command_yaw_dir == 0)
				command_yaw_dir = -1;
			else
				command_yaw_dir = 1;

			if (command_yaw_relative == 1){
				// relative
				command_yaw_delta	= command_cond_queue.alt * 100;

			}else{
				// absolute
				command_yaw_end		= command_cond_queue.alt * 100;

				// calculate the delta travel in deg * 100
				if(command_yaw_dir == 1){
					if(command_yaw_start >= command_yaw_end){
						command_yaw_delta = 36000 - (command_yaw_start - command_yaw_end);
					}else{
						command_yaw_delta = command_yaw_end - command_yaw_start;
					}
				}else{
					if(command_yaw_start > command_yaw_end){
						command_yaw_delta = command_yaw_start - command_yaw_end;
					}else{
						command_yaw_delta = 36000 + (command_yaw_start - command_yaw_end);
					}
				}
				command_yaw_delta = wrap_360(command_yaw_delta);
			}


			// rate to turn deg per second - default is ten
			command_yaw_time	= (command_yaw_delta / command_yaw_speed) * 1000;
		}


		/********************************************************************************/
		// Verify Condition (May) commands
		/********************************************************************************/

		public function verify_wait_delay():Boolean
		{
			//Serial.print("vwd");
			if ((millis() - condition_start) > condition_value){
				//Serial.println("y");
				condition_value = 0;
				return true;
			}
			//Serial.println("n");
			return false;
		}

		public function verify_change_alt():Boolean
		{
			//Serial.printf("change_alt, ca:%d, na:%d\n", (int)current_loc.alt, (int)next_WP.alt);
			if (condition_start < next_WP.alt){
				// we are going higer
				if(current_loc.alt > next_WP.alt){
					return true;
				}
			}else{
				// we are going lower
				if(current_loc.alt < next_WP.alt){
					return true;
				}
			}
			return false;
		}

		public function verify_within_distance():Boolean
		{
			//Serial.printf("cond dist :%d\n", (int)condition_value);
			if (wp_distance < condition_value){
				condition_value = 0;
				return true;
			}
			return false;
		}

		public function verify_yaw():Boolean
		{
			//Serial.printf("vyaw %d\n", (int)(nav_yaw/100));

			if((millis() - command_yaw_start_time) > command_yaw_time){
				// time out
				// make sure we hold at the final desired yaw angle
				nav_yaw 	= command_yaw_end;
				auto_yaw 	= nav_yaw;

				//Serial.println("Y");
				return true;

			}else{
				// else we need to be at a certain place
				// power is a ratio of the time : .5 = half done
				var power:Number = (millis() - command_yaw_start_time) / command_yaw_time;

				nav_yaw		= command_yaw_start + (command_yaw_delta * power * command_yaw_dir);
				nav_yaw		= wrap_360(nav_yaw);
				auto_yaw 	= nav_yaw;
				//Serial.printf("ny %ld\n",nav_yaw);
				return false;
			}
		}

		/********************************************************************************/
		//	Do (Now) commands
		/********************************************************************************/

		public function do_change_speed():void
		{
			g.waypoint_speed_max = command_cond_queue.p1 * 100;
		}

		public function do_target_yaw():void
		{
			yaw_tracking = command_cond_queue.p1;

			if(yaw_tracking == MAV_ROI_LOCATION){
				target_WP = command_cond_queue;
			}
		}

		public function do_loiter_at_location():void
		{
			next_WP = current_loc;
		}

		public function do_jump():void
		{
			// Used to track the state of the jump command in Mission scripting
			// -10 is a value that means the register is unused
			// when in use, it contains the current remaining jumps
			//static int8_t jump = -10;								// used to track loops in jump command

			//Serial.printf("do Jump: %d\n", jump);

			if(jump == -10){
				//Serial.printf("Fresh Jump\n");
				// we use a locally stored index for jump
				jump = command_cond_queue.lat;
			}
			//Serial.printf("Jumps left: %d\n",jump);

			if(jump > 0) {
				//Serial.printf("Do Jump to %d\n",command_cond_queue.p1);
				jump--;
				change_command(command_cond_queue.p1);

			} else if (jump == 0){
				//Serial.printf("Did last jump\n");
				// we're done, move along
				jump = -11;

			} else if (jump == -1) {
				//Serial.printf("jumpForever\n");
				// repeat forever
				change_command(command_cond_queue.p1);
			}
		}

		public function do_set_home():void
		{
			if(command_cond_queue.p1 == 1) {
				init_home();
			} else {
				home.id		= MAV_CMD_NAV_WAYPOINT;
				home.lng	= command_cond_queue.lng;				// Lon * 10**7
				home.lat	= command_cond_queue.lat;				// Lat * 10**7
				home.alt	= Math.max(command_cond_queue.alt, 0);
				home_is_set = true;
			}
		}

		public function do_set_servo():void
		{
			//apm_rc.OutputCh(command_cond_queue.p1 - 1, command_cond_queue.alt);
		}

		public function do_set_relay():void
		{
			if (command_cond_queue.p1 == 1) {
				relay.on();
			} else if (command_cond_queue.p1 == 0) {
				relay.off();
			}else{
				relay.toggle();
			}
		}

		public function do_repeat_servo():void
		{
			event_id = command_cond_queue.p1 - 1;

			if(command_cond_queue.p1 >= CH_5 + 1 && command_cond_queue.p1 <= CH_8 + 1) {

				event_timer		= 0;
				event_value		= command_cond_queue.alt;
				event_repeat	= command_cond_queue.lat * 2;
				event_delay		= command_cond_queue.lng * 500.0; // /2 (half cycle time) * 1000 (convert to milliseconds)

				switch(command_cond_queue.p1) {
					case CH_5:
						event_undo_value = g.rc_5.radio_trim;
						break;
					case CH_6:
						event_undo_value = g.rc_6.radio_trim;
						break;
					case CH_7:
						event_undo_value = g.rc_7.radio_trim;
						break;
					case CH_8:
						event_undo_value = g.rc_8.radio_trim;
						break;
				}
				update_events();
			}
		}

		public function do_repeat_relay():void
		{
			event_id		= RELAY_TOGGLE;
			event_timer		= 0;
			event_delay		= command_cond_queue.lat * 500.0; // /2 (half cycle time) * 1000 (convert to milliseconds)
			event_repeat	= command_cond_queue.alt * 2;
			update_events();
		}
		/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

		// For changing active command mid-mission
		//----------------------------------------
		public function change_command(cmd_index:int):void
		{
			//Serial.printf("change_command: %d\n",cmd_index );
			// limit range
			cmd_index = Math.min(g.command_total-1, cmd_index);

			// load command
			var temp:Location  = get_cmd_with_index(cmd_index);

			//Serial.printf("loading cmd: %d with id:%d\n", cmd_index, temp.id);

			// verify it's a nav command
			if (temp.id > MAV_CMD_NAV_LAST ){
				//gcs_send_text_P(SEVERITY_LOW,PSTR("error: non-Nav cmd"));

			} else {
				// clear out command queue
				init_commands();

				// copy command to the queue
				command_nav_queue		= temp;
				command_nav_index 		= cmd_index;
				execute_nav_command();
			}
		}

		// called by 10 Hz loop
		// --------------------
		public function update_commands():void
		{
			//Serial.printf("update_commands: %d\n",increment );
			// A: if we do not have any commands there is nothing to do
			// B: We have completed the mission, don't redo the mission
			// XXX debug
			//uint8_t tmp = g.command_index.get();
			//Serial.printf("command_index %u \n", tmp);

			if (g.command_total <= 1 || g.command_index >= 127)
				return;

			if(command_nav_queue.id == NO_COMMAND){
				// Our queue is empty
				// fill command queue with a new command if available, or exit mission
				// -------------------------------------------------------------------
				if (command_nav_index < (g.command_total -1)) {

					command_nav_index++;
					command_nav_queue = get_cmd_with_index(command_nav_index);

					if (command_nav_queue.id <= MAV_CMD_NAV_LAST ){
						execute_nav_command();
					} else{
						// this is a conditional command so we skip it
						command_nav_queue.id = NO_COMMAND;
					}
				}else{
					trace("OO Commands, land_complete = ", land_complete);
					// we are out of commands
					g.command_index  = command_nav_index = 255;
					// if we are on the ground, enter stabilize, else Land
					if (land_complete == true){
						// we will disarm the motors after landing.
					} else {
						// If the approach altitude is valid (above 1m), do approach, else land
						if(g.rtl_approach_alt >= 1){
							set_mode(LOITER);
							set_new_altitude(g.rtl_approach_alt);
						}else{
							set_mode(LAND);
						}
					}
				}
			}

			if(command_cond_queue.id == NO_COMMAND){
				// Our queue is empty
				// fill command queue with a new command if available, or do nothing
				// -------------------------------------------------------------------

				// no nav commands completed yet
				if (prev_nav_index == NO_COMMAND)
					return;

				if (command_cond_index >= command_nav_index){
					// don't process the fututre
					//command_cond_index = NO_COMMAND;
					return;

				}else if (command_cond_index == NO_COMMAND){
					// start from scratch
					// look at command after the most recent completed nav
					command_cond_index = prev_nav_index + 1;

				}else{
					// we've completed 1 cond, look at next command for another
					command_cond_index++;
				}

				if(command_cond_index < (g.command_total -2)){
					// we're OK to load a new command (last command must be a nav command)
					command_cond_queue = get_cmd_with_index(command_cond_index);

					if (command_cond_queue.id > MAV_CMD_CONDITION_LAST){
						// this is a do now command
						process_now_command();

						// clear command queue
						command_cond_queue.id = NO_COMMAND;

					}else if (command_cond_queue.id > MAV_CMD_NAV_LAST ){
						// this is a conditional command
						process_cond_command();

					}else{
						// this is a nav command, don't process
						// clear the command conditional queue and index
						prev_nav_index			= NO_COMMAND;
						command_cond_index 		= NO_COMMAND;
						command_cond_queue.id 	= NO_COMMAND;
					}

				}
			}
		}

		public function execute_nav_command():void
		{
			// This is what we report to MAVLINK
			g.command_index  = command_nav_index;

			// Save CMD to Log
			//if (g.log_bitmask & MASK_LOG_CMD)
				Log_Write_Cmd(g.command_index, command_nav_queue);

			// clear navigation prameters
			reset_nav_params();

			// Act on the new command
			process_nav_command();

			// clear May indexes to force loading of more commands
			// existing May commands are tossed.
			command_cond_index	= NO_COMMAND;
		}

		// called with GPS navigation update - not constantly
		public function verify_commands():void
		{
			if(verify_must()){
				//Serial.printf("verified must cmd %d\n" , command_nav_index);
				trace("verified must cmd", command_nav_index);
				command_nav_queue.id = NO_COMMAND;

				// store our most recent executed nav command
				prev_nav_index = command_nav_index;

				// Wipe existing conditionals
				command_cond_index 		= NO_COMMAND;
				command_cond_queue.id 	= NO_COMMAND;

			}else{
				//Serial.printf("verified must false %d\n" , command_nav_index);
			}

			if(verify_may()){
				//Serial.printf("verified may cmd %d\n" , command_cond_index);
				command_cond_queue.id = NO_COMMAND;
			}
		}

		// ---------------------------------------------------------------
		// control_modes.pde
		// ---------------------------------------------------------------

		public function read_control_switch():void
		{
			//static bool switch_debouncer = false;

			var switchPosition:int = readSwitch();

			if (oldSwitchPosition != switchPosition){
				if(switch_debouncer){
					oldSwitchPosition 	= switchPosition;
					switch_debouncer 	= false;

					set_mode(flight_modes[switchPosition]);

					if(g.ch7_option != CH7_SIMPLE_MODE){
						// set Simple mode using stored paramters from Mission planner
						// rather than by the control switch
						do_simple = (g.simple_modes & (1 << switchPosition)) as Boolean;
					}
				}else{
					switch_debouncer 	= true;
				}
			}
		}

		public function readSwitch():int
		{
			return radio_switch_position;
		}

		public function reset_control_switch():void
		{
			oldSwitchPosition = -1;
			read_control_switch();
		}

		// read at 10 hz
		// set this to your trainer switch
		public function read_trim_switch():void
		{
			do_simple = g.simple_checkbox.getSelected();

			// this is the normal operation set by the mission planner
			if(g.ch7_option == CH7_SIMPLE_MODE){
				//do_simple = (g.rc_7.radio_in > CH_7_PWM_TRIGGER);

			}else if (g.ch7_option == CH7_RTL){
				if (trim_flag == false && g.rc_7.radio_in > CH_7_PWM_TRIGGER){
					trim_flag = true;
					set_mode(RTL);
				}

				if (trim_flag == true && g.rc_7.control_in < 800){
					trim_flag = false;
					//if (control_mode == RTL || control_mode == LOITER){
						reset_control_switch();
					//}
				}

			}else if (g.ch7_option == CH7_SAVE_WP){

				if (g.rc_7.radio_in > CH_7_PWM_TRIGGER){ // switch is engaged
					trim_flag = true;
				}else{ // switch is disengaged
					if(trim_flag){
						trim_flag = false;

						if(control_mode == AUTO){
							// reset the mission
							CH7_wp_index = 0;
							g.command_total = 1;
							set_mode(RTL);
							return;
						}

						if(CH7_wp_index == 0){
							var tmp:Location = home.clone();
							// this is our first WP, let's save WP 1 as a takeoff
							// increment index to WP index of 1 (home is stored at 0)
							CH7_wp_index = 1;

							// set our location ID to 16, MAV_CMD_NAV_WAYPOINT
							tmp.id = MAV_CMD_NAV_TAKEOFF;
							tmp.alt = current_loc.alt;

							// save command:
							// we use the current altitude to be the target for takeoff.
							// only altitude will matter to the AP mission script for takeoff.
							// If we are above the altitude, we will skip the command.
							trace("save loc");
							set_cmd_with_index(tmp, CH7_wp_index);
						}

						// increment index
						CH7_wp_index++;

						// set the next_WP (home is stored at 0)
						// max out at 100 since I think we need to stay under the EEPROM limit
						CH7_wp_index = constrain(CH7_wp_index, 1, 100);

						if(g.rc_3.control_in > 0){
							// set our location ID to 16, MAV_CMD_NAV_WAYPOINT
							current_loc.id = MAV_CMD_NAV_WAYPOINT;
						}else{
							// set our location ID to 21, MAV_CMD_NAV_LAND
							current_loc.id = MAV_CMD_NAV_LAND;
						}

						// save command
						set_cmd_with_index(current_loc, CH7_wp_index);

						copter_leds_nav_blink = 10;	// Cause the CopterLEDs to blink twice to indicate saved waypoint

						// 0 = home
						// 1 = takeoff
						// 2 = WP 2
						// 3 = command total
					}
				}
			}else if (g.ch7_option == CH7_AUTO_TRIM){
				//if (g.rc_7.radio_in > CH_7_PWM_TRIGGER){
					//auto_level_counter = 10;
				//}
			}
		}

		// ----------------------------------------
		// Events.pde
		// ----------------------------------------

		/*
			This event will be called when the failsafe changes
			boolean failsafe reflects the current state
		*/
		public function failsafe_on_event():void
		{
			// This is how to handle a failsafe.
			switch(control_mode)
			{
				case AUTO:
					if (g.throttle_fs_action == 1) {
						// do_rtl sets the altitude to the current altitude by default
						set_mode(RTL);
						// We add an additional 10m to the current altitude
						//next_WP.alt += 1000;
						set_new_altitude(target_altitude + 1000);
					}
					// 2 = Stay in AUTO and ignore failsafe
					break;

				default:
					if(home_is_set == true){
						// same as above ^
						// do_rtl sets the altitude to the current altitude by default
						set_mode(RTL);
						// We add an additional 10m to the current altitude
						//next_WP.alt += 1000;
						set_new_altitude(target_altitude + 1000);
					}else{
						// We have no GPS so we must land
						set_mode(LAND);
					}
					break;
			}
		}

		public function failsafe_off_event():void
		{
			if (g.throttle_fs_action == 2){
				// We're back in radio contact
				// return to AP
				// ---------------------------

				// re-read the switch so we can return to our preferred mode
				// --------------------------------------------------------
				reset_control_switch();


			}else if (g.throttle_fs_action == 1){
				// We're back in radio contact
				// return to Home
				// we should already be in RTL and throttle set to cruise
				// ------------------------------------------------------
				set_mode(RTL);
			}
		}

		public function low_battery_event():void
		{
			trace("Low Battery!")
			low_batt = true;

			// if we are in Auto mode, come home
			if(control_mode >= AUTO)
				set_mode(RTL);
		}


		public function update_events():void // Used for MAV_CMD_DO_REPEAT_SERVO and MAV_CMD_DO_REPEAT_RELAY
		{/*
			if(event_repeat == 0 || (millis() - event_timer) < event_delay)
				return;

			if (event_repeat > 0){
				event_repeat --;
			}

			if(event_repeat != 0) {		// event_repeat = -1 means repeat forever
				event_timer = millis();

				if (event_id >= CH_5 && event_id <= CH_8) {
					if(event_repeat%2) {
						apm_rc.OutputCh(event_id, event_value); // send to Servos
					} else {
						apm_rc.OutputCh(event_id, event_undo_value);
					}
				}

				if  (event_id == RELAY_TOGGLE) {
					relay.toggle();
				}
			}
			*/
		}

		// -----------------------------------------------------------------------------------
		// flip.pde
		//------------------------------------------------------------------------------------

		public function init_flip():void
		{
			if(do_flip == false){
				do_flip = true;
				flip_timer = 0;
				flip_state = 0;
			}
		}


		public function roll_flip():void
		{
			// Yaw
			g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);

			// Pitch
			g.rc_2.servo_out = get_stabilize_pitch(0);

			// Roll State machine
			switch (flip_state){
				case 0: // Step 1 : Initialize
					flip_timer = 0;
					flip_state++;
					break;
				case 1: // Step 2 : Increase throttle to start maneuver
					if (flip_timer < 95){ 	// .5 seconds
						g.rc_1.servo_out = get_stabilize_roll(0);
						g.rc_3.servo_out = g.rc_3.control_in + AAP_THR_INC;
						flip_timer++;
					}else{
						flip_state++;
						flip_timer = 0;
					}
					break;

				case 2: // Step 3 : ROLL (until we reach a certain angle [45deg])
					if (ahrs.roll_sensor < 4500){
						// Roll control
						g.rc_1.servo_out = AAP_ROLL_OUT;
						g.rc_3.servo_out = g.rc_3.control_in;
					}else{
						flip_state++;
					}
					break;

				case 3: // Step 4 : CONTINUE ROLL (until we reach a certain angle [-45deg])
					if((ahrs.roll_sensor >= 4500) || (ahrs.roll_sensor < -9000)){// we are in second half of roll
						g.rc_1.servo_out = 0;
						g.rc_3.servo_out = g.rc_3.control_in - AAP_THR_DEC;
					}else{
						flip_state++;
					}
					break;

				case 4: // Step 5 : Increase throttle to stop the descend
					if (flip_timer < 90){ // .5 seconds
						g.rc_1.servo_out = get_stabilize_roll(0);
						g.rc_3.servo_out = g.rc_3.control_in + AAP_THR_INC + 30;
						flip_timer++;
					}else{
						flip_state++;
						flip_timer = 0;
					}
					break;

				case 5: // exit mode
					flip_timer = 0;
					flip_state = 0;
					do_flip = false;
					break;
			}
		}

		// ---------------------------------------------------------------
		// inertia.pde
		// ---------------------------------------------------------------

		// generates a new location and velocity in space based on inertia
		// Calc 100 hz
		public function calc_inertia():void
		{
			//ahrs.accel.x *= accels_scale.x;
			//ahrs.accel.y *= accels_scale.y;
			//ahrs.accel.z *= accels_scale.z;
			accels_rotated 	= ahrs.dcm.transformVector(ahrs.accel);
			accels_rotated.z += 9.805;								// remove influence of gravity


			// rising 		= 2
			// neutral 		= 0
			// falling 		= -2


			// ACC Y POS = going EAST
			// ACC X POS = going North
			// ACC Z POS = going DOWN (lets flip this)

			// Integrate accels to get the velocity
			// ------------------------------------
			accels_velocity.x += accels_rotated.y * G_Dt * 100;
			accels_velocity.y += accels_rotated.x * G_Dt * 100;
			accels_velocity.z -= accels_rotated.z * G_Dt * 100; // going up = negative accel.z
			// Temp is changed to world frame and we can use it normaly


			// Integrate Velocity to get the Position
			// ------------------------------------
			accels_position.x += accels_velocity.x * G_Dt;
			accels_position.y += accels_velocity.y * G_Dt;
			accels_position.z += accels_velocity.z * G_Dt;
			//trace(accels_velocity.x, copter.velocity.y, accels_position.x, copter.position.x);

			var dcm_t:Matrix3D = ahrs.dcm.clone();
			dcm_t.transpose();
			accels_scale					= dcm_t.transformVector(speed_error);
			//accels_scale.z -=
		}

		public function xy_error_correction():void
		{
			// Calculate speed error
			// ---------------------
			speed_error.x 		= x_actual_speed - accels_velocity.x;
			speed_error.y 		= y_actual_speed - accels_velocity.y;

			// Calculate position error
			// ------------------------
			position_error.x	= accels_position.x - current_loc.lng;
			position_error.y	= accels_position.y - current_loc.lat;

			// correct integrated velocity by speed_error
			// this number must be small or we will bring back sensor latency
			// -------------------------------------------
			accels_velocity.x	+= speed_error.x * g.xy_speed_correction;
			accels_velocity.y	+= speed_error.y * g.xy_speed_correction;

			// Error correct the accels to deal with calibration, drift and noise
			// ------------------------------------------------------------------
			//accels_position.x	 -= position_error.x * g.xy_pos_correction; // OK
			//accels_position.y	 -= position_error.y * g.xy_pos_correction; // OK

			// update our accel offsets
			// -------------------------
			//accels_scale.x		 += position_error.x * offset_x_gain;
			//accels_scale.y		 += position_error.y * offset_y_gain;

			//accels_position.x = 0;
			//accels_position.y = 0;

			//trace("accels_scale:\t", Math.floor(accels_scale.x), Math.floor(accels_scale.y), Math.floor(accels_scale.z));
		}

		public function z_error_correction():void
		{
			// Calculate speed error
			// ---------------------
			speed_error.z 		= climb_rate - accels_velocity.z;
			position_error.z	= accels_position.z - current_loc.alt;

			// correct integrated velocity by speed_error
			// this number must be small or we will bring back sensor latency
			// -------------------------------------------
			accels_velocity.z	+= speed_error.z * g.speed_correction_z; 	//  0.0350;

			// ------------------------------------------------------------------
			//accels_position.z	 -= position_error.z * g.z_pos_correction;

			//if(g.test)
			//	offset_z_gain = Math.abs(position_error.z) * 0.000001;

			//trace(offset_z_gain)

			// update our accel offsets
			// -------------------------
			//accels_scale.z		-= position_error.z * offset_z_gain;

			accels_position.z = 0;
		}

		public function calibrate_accels():void
		{
			/*
			trace("calibrate_accels ");

			// sets accels_velocity to 0,0,0
			zero_accels();

			accels_scale.x = 1;
			accels_scale.y = 1;
			accels_scale.z = 1;

			var i:int;

			//for (i = 0; i < 200; i++){
			//	delay(10);
			//	read_AHRS();
			//}

			for (i = 0; i < 100; i++){
				delay(10);
				//ahrs.accel	= accel_earth.clone();
				//ahrs.accel.x	= 0 * g.accel_bias_x;
				//ahrs.accel.y	= 0 * g.accel_bias_y;
				ahrs.accel.z	= -9.805 * g.accel_bias_z;

				//accels_velocity.x += ahrs.accel.x;
				//accels_velocity.y += ahrs.accel.y;
				accels_velocity.z += ahrs.accel.z;
			}

			//accels_velocity.x /= 100;
			//accels_velocity.y /= 100;
			accels_velocity.z /= 100;

			// scale Z :
			accels_scale.z = -9.805 / accels_velocity.z;

			trace("accels_velocity.z ", accels_velocity.z, "accels_scale.z ", accels_scale.z);
			*/
		}

		public function zero_accels():void
		{
			accels_rotated.x 	= 0;
			accels_rotated.y 	= 0;
			accels_rotated.z 	= 0;

			accels_velocity.x 	= 0;
			accels_velocity.y 	= 0;
			accels_velocity.z 	= 0;
		}

		// ---------------------------------------------------------------
		// motors.pde
		// ---------------------------------------------------------------

		public function init_arm_motors():void
		{
			motors.armed = true;

			// Remember Orientation
			// --------------------
			init_simple_bearing();

			// Reset home position
			// -------------------
			if(home_is_set)
				init_home();

			calibrate_accels();

			// all I terms are invalid
			// -----------------------
			reset_I_all();
			update_arm_label();
		}

		public function init_disarm_motors():void
		{
			//trace("Disarm Motors");
			takeoff_complete = false;
			//stopSIM();
			motors.armed = false;
			update_arm_label();
			//g.throttle_cruise.save();
		}


		public function set_servos_4()
		{
			if (motors.armed == true && motors.auto_armed == true) {
				// creates the radio_out and pwm_out values
				output_motors_armed();
			} else{
				output_motors_disarmed();
			}
		}

		public function output_motors_armed()
		{
			var roll_out	:int = 0
			var pitch_out	:int = 0
			var out_min		:int = g.rc_3.radio_min;
			var out_max 	:int = g.rc_3.radio_max;

			// Throttle is 0 to 1000 only
			g.rc_3.servo_out 	= constrain(g.rc_3.servo_out, 0, g.throttle_max);

			if(g.rc_3.servo_out > 0)
				out_min = g.rc_3.radio_min + g.throttle_min;

			g.rc_1.calc_pwm();
			g.rc_2.calc_pwm();
			g.rc_3.calc_pwm();
			g.rc_4.calc_pwm();

			roll_out 	 		= g.rc_1.pwm_out; // 157 pwm
			pitch_out 	 		= g.rc_2.pwm_out;

			// left
			motor_out[CH_1]		= g.rc_3.radio_out - roll_out;
			// right
			motor_out[CH_2]		= g.rc_3.radio_out + roll_out;
			// front
			motor_out[CH_3]		= g.rc_3.radio_out + pitch_out;
			// back
			motor_out[CH_4] 	= g.rc_3.radio_out - pitch_out;


			// Yaw input
			motor_out[MOT_1]		+=  g.rc_4.pwm_out; 	// CCW
			motor_out[MOT_2]		+=  g.rc_4.pwm_out; 	// CCW
			motor_out[MOT_3]		-=  g.rc_4.pwm_out; 	// CW
			motor_out[MOT_4]	 	-=  g.rc_4.pwm_out; 	// CW

			/* We need to clip motor output at out_max. When cipping a motors
			 * output we also need to compensate for the instability by
			 * lowering the opposite motor by the same proportion. This
			 * ensures that we retain control when one or more of the motors
			 * is at its maximum output
			 */

			for (var i:int = MOT_1; i <= MOT_4; i++){
				if(motor_out[i] > out_max){
					// note that i^1 is the opposite motor
					motor_out[i ^ 1] -= motor_out[i] - out_max;
					motor_out[i] = out_max;
				}
			}

			// limit output so motors don't stop
			motor_out[MOT_1]	= Math.max(motor_out[MOT_1], 	out_min);
			motor_out[MOT_2]	= Math.max(motor_out[MOT_2], 	out_min);
			motor_out[MOT_3]	= Math.max(motor_out[MOT_3], 	out_min);
			motor_out[MOT_4]	= Math.max(motor_out[MOT_4], 	out_min);


			// cut motors
			if(g.rc_3.servo_out == 0){
				motor_out[MOT_1]	= g.rc_3.radio_min;
				motor_out[MOT_2]	= g.rc_3.radio_min;
				motor_out[MOT_3]	= g.rc_3.radio_min;
				motor_out[MOT_4]	= g.rc_3.radio_min;
			}


			apm_rc.outputCh(MOT_1, motor_out[MOT_1]);
			apm_rc.outputCh(MOT_2, motor_out[MOT_2]);
			apm_rc.outputCh(MOT_3, motor_out[MOT_3]);
			apm_rc.outputCh(MOT_4, motor_out[MOT_4]); // 1000 : 2000
		}

		public function output_motors_disarmed()
		{
			if(g.rc_3.control_in > 0){
				// we have pushed up the throttle
				// remove safety
				motors.auto_armed = true;
			}

			// Send commands to motors
			apm_rc.outputCh(CH_1, g.rc_3.radio_min);
			apm_rc.outputCh(CH_2, g.rc_3.radio_min);
			apm_rc.outputCh(CH_3, g.rc_3.radio_min);
			apm_rc.outputCh(CH_4, g.rc_3.radio_min);

		}

		// -----------------------------------------------------------------------------------
		// Navigation
		//------------------------------------------------------------------------------------

		public function navigate():void
		{
			// waypoint distance from plane in cm
			// ---------------------------------------
			wp_distance 	= get_distance(current_loc, next_WP);
			home_distance 	= get_distance(current_loc, home);

			// target_bearing is where we should be heading
			// --------------------------------------------
			target_bearing 			= get_bearing(current_loc, next_WP);
			home_to_copter_bearing 	= get_bearing(home, current_loc);
		}

		public function check_missed_wp():Boolean
		{
			var temp:Number;
			temp = target_bearing - original_target_bearing;
			temp = wrap_180(temp);
			return (Math.abs(temp) > 10000);	// we passed the waypoint by 100 degrees
		}

		public function calc_XY_velocity()
		{
			// called after GPS read
			// offset calculation of GPS speed:
			// used for estimations below 1.5m/s
			// y_GPS_speed positve = Up
			// x_GPS_speed positve = Right

			// initialise last_longitude,
			// Disabled for SIM - too easy to trip
			//if(last_longitude == 0){
			//	last_longitude 	= g_gps.longitude;
			//	last_latitude 	= g_gps.latitude;
			//}

			var tmp:Number = 1.0/dTnav;

			x_actual_speed 	= (g_gps.longitude - last_longitude) * tmp;
			y_actual_speed 	= (g_gps.latitude  - last_latitude)  * tmp;

			last_longitude 	= g_gps.longitude;
			last_latitude 	= g_gps.latitude;

			//if(g_gps.ground_speed > 150){
			//	float temp = radians(g_gps.ground_course/100.0);
			//	x_actual_speed = g_gps.ground_speed * sin(temp);
			//	y_actual_speed = g_gps.ground_speed * cos(temp);
			//}

			if(g.inertia_checkbox.getSelected()){
				xy_error_correction();
			}

			if(g.lead_filter_checkbox.getSelected()){
				if(g.inertia_checkbox.getSelected()){
					current_loc.lng = xLeadFilter.get_position(g_gps.longitude, accels_velocity.x);
					current_loc.lat = yLeadFilter.get_position(g_gps.latitude,  accels_velocity.y);
				}else{
					current_loc.lng = xLeadFilter.get_position(g_gps.longitude, x_actual_speed);
					current_loc.lat = yLeadFilter.get_position(g_gps.latitude,  y_actual_speed);
				}
			}else{
				current_loc.lng = g_gps.longitude;
				current_loc.lat = g_gps.latitude;
			}


			/*
				// Ryan Beall's forward estimator:
				var speed_input:Number;
				speed_input = lon_filter.apply((g_gps.longitude - last_longitude) * tmp);
				//trace(speed_input);
				last_longitude = g_gps.longitude;


				//if(speed_input > 40){
					x_actual_speed 	= speed_input + (speed_input - speed_old) * 1;
					if(limit < 100)
						trace(copter.loc.lng, g_gps.longitude, (copter.loc.lng - g_gps.longitude), copter.velocity.x, speed_input, x_actual_speed, ((speed_input - speed_old) * 2));

					//g_gps.longitude += dTnav * (speed_input - speed_old);
					speed_old 	= speed_input;
				//}
				//trace(speed_new);
			*/
		}

		public function calc_location_error(next_loc:Location):void
		{
			/*
			Becuase we are using lat and lon to do our distance errors here's a quick chart:
			100 	= 1m
			1000 	= 11m	 = 36 feet
			1800 	= 19.80m = 60 feet
			3000 	= 33m
			10000 	= 111m
			*/

			// X Error
			long_error	= next_loc.lng - current_loc.lng;

			// Y Error
			lat_error 	= next_loc.lat  - copter.loc.lat // ideal position data
		}

		public function calc_loiter(x_error:Number, y_error:Number):void
		{
			var output:Number;

			// East / West
			x_target_speed			= g.pi_loiter_lon.get_p(x_error);			// calculate desired speed from lon error

			if(g.inertia_checkbox.getSelected()){
				x_rate_error		= x_target_speed - accels_velocity.x;			// calc the speed error
			}else{
				x_rate_error		= x_target_speed - x_actual_speed;		// calc the speed error
			}

			p_loiter_rate			= g.pid_loiter_rate_lon.get_p(x_rate_error);
			i_loiter_rate			= g.pid_loiter_rate_lon.get_i(x_rate_error + x_error , dTnav);
			d_loiter_rate			= g.pid_loiter_rate_lon.get_d(x_error, dTnav);
			d_loiter_rate			= constrain(d_loiter_rate, -2000, 2000);

			// get rid of noise
			if (Math.abs(x_actual_speed) < 50)
				d_loiter_rate = 0;

			output					= p_loiter_rate + i_loiter_rate + d_loiter_rate;
			nav_lon					= constrain(output, -3200, 3200);			// 30°

			// North / South
			y_target_speed 	= g.pi_loiter_lat.get_p(y_error);			// calculate desired speed from lat error

			if(g.inertia_checkbox.getSelected()){
				y_rate_error		= y_target_speed - accels_velocity.y;			// calc the speed error
			}else{
				y_rate_error		= y_target_speed - y_actual_speed;		// calc the speed error
			}


			var p:Number	= g.pid_loiter_rate_lat.get_p(y_rate_error);
			var i:Number	= g.pid_loiter_rate_lat.get_i(y_rate_error + y_error, dTnav);
			var d:Number	= g.pid_loiter_rate_lat.get_d(y_error, dTnav);
			d				= constrain(d, -2000, 2000);

			// get rid of noise
			if (Math.abs(y_actual_speed) < 50)
				d = 0;

			output			= p + i + d;
			nav_lat			= constrain(output, -3200, 3200);

			// copy over I term to Nav_Rate
			g.pid_nav_lon.set_integrator(g.pid_loiter_rate_lon.get_integrator());
			g.pid_nav_lat.set_integrator(g.pid_loiter_rate_lat.get_integrator());
		}

		public function calc_nav_rate(max_speed:Number):void
		{
			var output:Number;
			var temp:Number
			var temp_x:Number
			var temp_y:Number
			var constr:Number = 1000;

			//constr = (g.test) ? 6000 : 400;

			// push us towards the original track
			update_crosstrack();

			var cross_speed:Number = crosstrack_error * -g.crosstrack_gain;

			cross_speed	= constrain(cross_speed, -200, 200);

			// rotate by 90 to deal with trig functions
			temp 			= (9000 - target_bearing) * RADX100;
			temp_x 			= Math.cos(temp);
			temp_y 			= Math.sin(temp);

			// rotate desired spped vector:
			x_target_speed 	= max_speed   * temp_x - cross_speed * temp_y;
			y_target_speed 	= cross_speed * temp_x + max_speed   * temp_y;

			// East / West
			// calculate rate error
			if(g.inertia_checkbox.getSelected()){
				x_rate_error		= x_target_speed - accels_velocity.x;			// calc the speed error
			}else{
				x_rate_error		= x_target_speed - x_actual_speed;		// calc the speed error
			}

			x_rate_error 	= constrain(x_rate_error, -constr, constr);
			p_nav_rate		= g.pid_nav_lon.get_p(x_rate_error);
			i_nav_rate		= g.pid_nav_lon.get_i(x_rate_error, dTnav);
			d_nav_rate		= g.pid_nav_lon.get_d(x_rate_error, dTnav);
			nav_lon			= p_nav_rate + i_nav_rate + d_nav_rate;
			var tmp:Number  = (x_target_speed * x_target_speed * g.tilt_comp) / 10000;

			if(x_target_speed < 0)
				tmp = -tmp;
			nav_lon			+= tmp;
			nav_lon			= constrain(nav_lon, -3200, 3200);

			// North / South
			// calculate rate error
			if(g.inertia_checkbox.getSelected()){
				y_rate_error		= y_target_speed - accels_velocity.y;			// calc the speed error
			}else{
				y_rate_error		= y_target_speed - y_actual_speed;		// calc the speed error
			}
			y_rate_error 	= constrain(y_rate_error, -constr, constr);	// added a rate error limit to keep pitching down to a minimum
			nav_lat			= g.pid_nav_lat.get_pid(y_rate_error, dTnav);
			tmp  			= (y_target_speed * y_target_speed * g.tilt_comp)/10000;

			if(y_target_speed < 0)
				tmp = -tmp;

			nav_lat			+= tmp;
			nav_lat			= constrain(nav_lat, -3200, 3200);

			// copy over I term to Loiter_Rate
			g.pid_loiter_rate_lon.set_integrator(g.pid_nav_lon.get_integrator());
			g.pid_loiter_rate_lat.set_integrator(g.pid_nav_lat.get_integrator());
		}


		// this calculation rotates our World frame of reference to the copter's frame of reference
		// We use the DCM's matrix to precalculate these trig values at 50hz
		public function calc_loiter_pitch_roll():void
		{
			// rotate the vector
			auto_roll 	= nav_lon * sin_yaw_y - nav_lat * cos_yaw_x;
			auto_pitch 	= nav_lon * cos_yaw_x + nav_lat * sin_yaw_y;

			// flip pitch because forward is negative
			auto_pitch = -auto_pitch;
		}

		public function limit_pitch_and_roll(z_error:Number):void
		{
			if(z_error < 100)
				return;

			// do nothing unless we are below 1m
			//z_error -= 100;

			z_error = constrain((z_error -100), 0, 200 );

			var fix:Number 		= z_error /200;
			var aroll:Number 	= auto_roll;
			var tmp:Number 		= fix * auto_roll;

			auto_roll 			= auto_roll - (fix * auto_roll);

			//trace(z_error, aroll, tmp, 	auto_roll, ahrs.roll_sensor);
//					300   -3000  -3000   0         -12.73333333333276

		}

		public function get_desired_speed(max_speed:Number, _slow:Boolean):Number
		{
			/*
			|< WP Radius
			0  1   2   3   4   5   6   7   8m
			...|...|...|...|...|...|...|...|
				  100  |  200	  300	  400cm/s
					   |  		 		            +|+
					   |< we should slow to 1.5 m/s as we hit the target
			*/

			// max_speed is default 600 or 6m/s
			if(_slow){
				max_speed		= Math.min(max_speed, wp_distance / 3);
				max_speed		= Math.max(max_speed, 0);
			}else{
				max_speed		= Math.min(max_speed, wp_distance / 3);
				max_speed		= Math.max(max_speed, WAYPOINT_SPEED_MIN);	// go at least 100cm/s
			}

			// limit the ramp up of the speed
			// waypoint_speed_gov is reset to 0 at each new WP command
			if(max_speed > waypoint_speed_gov){
				waypoint_speed_gov += (100.0 * dTnav); // increase at .5/ms
				max_speed = waypoint_speed_gov;
			}

			return max_speed;
		}

		public function get_desired_climb_rate(speed:Number):Number
		{
			/*
			|< WP Radius
			0  1   2   3   4   5   6   7   8m
			...|...|...|...|...|...|...|...|
				  100  |  200	  300	  400cm/s
					   |  		 		            +|+
					   |< we should slow to 1.5 m/s as we hit the target
			*/

			if(alt_change_flag == ASCENDING){
				//speed		= Math.min(speed, altitude_error / 3);
				speed		= constrain(altitude_error / 4, 30, speed);

			}else if(alt_change_flag == DESCENDING){
				//speed		= Math.max(speed, altitude_error / 3);
				speed		= constrain(altitude_error / 6, -speed, -10);
				trace("desired speed: ", altitude_error / 6)

			}else return 0;

			// limit the ramp up of the speed
			// waypoint_speed_gov is reset to 0 at each new WP command
			//if(speed > waypoint_speed_gov){
			//	climbrate_gov += (100.0 * dTnav); // increase at .5/ms
			//	speed = waypoint_speed_gov;
			//}

			return speed;
		}



		public function update_crosstrack():void
		{
			// Crosstrack Error
			// ----------------
			// If we are too far off or too close we don't do track following
			var temp:Number 	= (target_bearing - original_target_bearing) * RADX100;
			crosstrack_error 	= Math.sin(temp) * wp_distance;	 // Meters we are off track line
			crosstrack_score += Math.abs(crosstrack_error * .01); // for judging
		}

		public function get_altitude_error():Number
		{
			// Next_WP alt is our target alt
			// It changes based on climb rate
			// until it reaches the target_altitude
			return target_altitude - current_loc.alt;
		}

		public function clear_new_altitude():void
		{
			alt_change_flag = REACHED_ALT;
		}

		public function force_new_altitude(_new_alt:Number):void
		{
			next_WP.alt 	= _new_alt;
			target_altitude = _new_alt;
			alt_change_flag = REACHED_ALT;
		}

		public function set_new_altitude(_new_alt:Number):void
		{
			if(_new_alt == current_loc.alt){
				force_new_altitude(_new_alt);
				return;
			}

			// We start at the current location altitude and gradually change alt
			next_WP.alt = current_loc.alt;

			// for calculating the delta time
			alt_change_timer = millis();

			// save the target altitude
			target_altitude = _new_alt;

			// reset our altitude integrator
			alt_change = 0;

			// save the original altitude
			original_altitude = current_loc.alt;

			// to decide if we have reached the target altitude
			if(target_altitude > original_altitude){
				// we are below, going up
				alt_change_flag = ASCENDING;
				//Serial.printf("go up\n");
			}else if(target_altitude < original_altitude){
				// we are above, going down
				alt_change_flag = DESCENDING;
				//Serial.printf("go down\n");
			}else{
				// No Change
				alt_change_flag = REACHED_ALT;
				//Serial.printf("reached alt\n");
			}
			//Serial.printf("new alt: %d Org alt: %d\n", target_altitude, original_altitude);
		}

		public function get_new_altitude():Number
		{
			// returns a new next_WP.alt

			if(alt_change_flag == ASCENDING){
				// we are below, going up
				if(current_loc.alt >  target_altitude){
					alt_change_flag = REACHED_ALT;
				}

				// we shouldn't command past our target
				if(next_WP.alt >=  target_altitude){
					return target_altitude;
				}
			}else if (alt_change_flag == DESCENDING){
				// we are above, going down
				if(current_loc.alt <=  target_altitude)
					alt_change_flag = REACHED_ALT;

				// we shouldn't command past our target
				if(next_WP.alt <=  target_altitude){
					return target_altitude;
				}
			}

			// if we have reached our target altitude, return the target alt
			if(alt_change_flag == REACHED_ALT){
				return target_altitude;
			}

			var diff:Number 	= Math.abs(next_WP.alt - target_altitude);
			// scale is how we generate a desired rate from the elapsed time
			// a smaller scale means faster rates
			var _scale:Number 	= 4;

			if (next_WP.alt < target_altitude){
				// we are below the target alt
				if(diff < 200){
					_scale = 4;
				} else {
					_scale = 3;
				}
			}else {
				// we are above the target, going down
				if(diff < 400){
					_scale = 5;
				}
				if(diff < 100){
					_scale = 6;
				}
			}

			// we use the elapsed time as our altitude offset
			// 1000 = 1 sec
			// 1000 >> 4 = 64cm/s descent by default
			var change:Number = (millis() - alt_change_timer) >> _scale;

			if(alt_change_flag == ASCENDING){
				alt_change += change;
			}else{
				alt_change -= change;
			}
			// for generating delta time
			alt_change_timer = millis();
			return original_altitude + alt_change;
		}

		public function get_distance(loc1:Location, loc2:Location):Number
		{
			var dlat:int 	= (loc2.lat - loc1.lat);
			var dlong:int	= Math.floor((loc2.lng - loc1.lng) * scaleLongDown);
			dlong			= Math.sqrt(Math.pow(dlat,2) + Math.pow(dlong,2)) * 1.113195;
			return			dlong;
		}

		public function get_bearing(loc1:Location, loc2:Location):Number
		{
			var off_x:Number 	= loc2.lng - loc1.lng;
			var off_y:Number 	= (loc2.lat - loc1.lat) * scaleLongUp;
			var bearing:Number  = 9000 + Math.atan2(-off_y, off_x) * 5729.57795;
			if (bearing < 0) bearing += 36000;
			return Math.round(bearing);
		}



/********************************************************************************/
//
/********************************************************************************/


		// ----------------------------------------
		// radio.pde
		// ----------------------------------------

		public function default_dead_zones():void
		{
			g.rc_1.set_dead_zone(60);
			g.rc_2.set_dead_zone(60);
		    g.rc_3.set_dead_zone(60);
			g.rc_4.set_dead_zone(80);
		}

		public function init_rc_in():void
		{
			// set rc channel ranges
			g.rc_1.set_angle(4500);
			g.rc_2.set_angle(4500);
			g.rc_3.set_range(g.throttle_min, g.throttle_max);
			g.rc_4.set_angle(4500);

			// reverse: CW = left
			// normal:  CW = left???

			g.rc_1.set_type(g.rc_1.RC_CHANNEL_ANGLE_RAW);
			g.rc_2.set_type(g.rc_1.RC_CHANNEL_ANGLE_RAW);
			g.rc_4.set_type(g.rc_1.RC_CHANNEL_ANGLE_RAW);

			//set auxiliary ranges
			g.rc_5.set_range(0,1000);
			g.rc_6.set_range(0,1000);
			g.rc_7.set_range(0,1000);
			//g.rc_8.set_range(0,1000);

		}

		public function init_rc_out():void
		{
			g.rc_3.set_range_out(0,1000);
		}

		public function read_radio():void
		{
			if (apm_rc.getState() == 1){
				new_radio_frame = true;

				g.rc_1.set_pwm(apm_rc.InputCh(CH_1));
				g.rc_2.set_pwm(apm_rc.InputCh(CH_2));
				g.rc_4.set_pwm(apm_rc.InputCh(CH_4));
				g.rc_5.set_pwm(apm_rc.InputCh(CH_5));
				g.rc_6.set_pwm(apm_rc.InputCh(CH_6));
				g.rc_7.set_pwm(apm_rc.InputCh(CH_7));
				g.rc_8.set_pwm(apm_rc.InputCh(CH_8));

				// throttle
				// XXX SYNC - failsafe dropout fix
				var tmp:int = apm_rc.InputCh(CH_3);
				if(tmp > g.throttle_fs_value)
					g.rc_3.set_pwm(tmp);

				//trace("3 in", tmp, g.rc_3.radio_in, g.rc_3.control_in, g.rc_3.servo_out);

				//g.rc_3.control_in = Math.min(g.rc_3.control_in, g.throttle_max);

				// override user input
				//g.rc_1.control_in = user.get_roll();
				throttle_failsafe(tmp);
			}
		}

		public function throttle_failsafe(pwm:int):void
		{
			// Don't enter Failsafe if not enabled by user
			if(g.throttle_fs_enabled == 0)
				return;

			//check for failsafe and debounce funky reads
			// ------------------------------------------
			if (pwm < g.throttle_fs_value){
				// we detect a failsafe from radio
				// throttle has dropped below the mark
				failsafeCounter++;

				if (failsafeCounter == FS_COUNTER-1){ // 2
					// called right before trigger
					// do nothing
				}else if(failsafeCounter == FS_COUNTER) {
					// Don't enter Failsafe if we are not armed
					// home distance is in meters
					// This is to prevent accidental RTL
					if(motors.armed && takeoff_complete){
						trace("MSG FS ON ",pwm);
						set_failsafe(true);
					}
				}else if (failsafeCounter > FS_COUNTER){
					failsafeCounter = FS_COUNTER+1;
				}

			}else if(failsafeCounter > 0){
				// we are no longer in failsafe condition
				// but we need to recover quickly
				failsafeCounter--;
				if (failsafeCounter > 3){
					failsafeCounter = 3;
				}
				if (failsafeCounter == 1){
					trace("MSG FS OFF ");
				}else if(failsafeCounter == 0) {
					set_failsafe(false);
				}else if (failsafeCounter <0){
					failsafeCounter = -1;
				}
			}
		}



		// ----------------------------------------
		// Loging
		// ----------------------------------------
		private function Log_Write_Nav_Tuning():void
		{
			//			  wp_distance, (nav_bearing/100), long_error, lat_error, nav_lon, nav_lat, x_actual_speed, y_actual_speed, g.pid_nav_lon.get_integrator(), g.pid_nav_lat.get_integrator()
			trace("NTUN, "+ wp_distance +","+ (target_bearing/100)+","+  long_error+","+  lat_error+","+  nav_lon.toFixed(0)+","+  nav_lat.toFixed(0)+","+  x_actual_speed.toFixed(0)+","+  y_actual_speed.toFixed(0)+","+  g.pid_loiter_rate_lon.get_integrator()+","+  g.pid_loiter_rate_lat.get_integrator());

		}

		private function Log_Write_Control_Tuning():void
		{
			trace("CTUN,"+ g.rc_3.control_in +","+ 0 +","+  baro_alt  +","+  next_WP.alt +","+ nav_throttle +","+ angle_boost +","+ manual_boost +","+ climb_rate +","+ copter.throttle +","+ g.pi_alt_hold.get_integrator() +","+ g.pid_throttle.get_integrator());
		}
		private function Log_Write_Attitude():void
		{
			trace("ATT", ahrs.roll_sensor+","+  ahrs.pitch_sensor+","+  ahrs.yaw_sensor);
		}
		private function Log_Write_GPS():void
		{
			trace("GPS, 0, 0, " + ((wp_manager.lat_offset + current_loc.lat)/10000000) +", "+ ((wp_manager.lng_offset + current_loc.lng)/10000000) +", "+ current_loc.alt/100 +", "+ current_loc.alt/100 +", "+ x_actual_speed +", "+ target_bearing);
		}

		public function Log_Write_Cmd(index:int, cmd:Location)
		{
			trace("CMD, " + g.command_total+", "+ index + ", " + cmd.id + ", " + cmd.options + ", " + cmd.p1 + ", " + cmd.alt + ", " + (cmd.lat+ wp_manager.lat_offset) + ", " + (cmd.lng + wp_manager.lng_offset));
		}

		// ----------------------------------------
		// System.pde
		// ----------------------------------------
		public function set_mode(mode:int):void
		{
			// if we don't have GPS lock
			if(home_is_set == false){
				trace("set_mode, oh noes!", mode);
				// THOR
				// We don't care about Home if we don't have lock yet in Toy mode
				if(mode == TOY || mode == OF_LOITER){
					// nothing
				}else if (mode > ALT_HOLD){
					mode = STABILIZE;
				}
			}

			control_mode 		= mode;
			trace("Set Mode", flight_mode_strings[mode]);

			// update pulldown in GUI
			modeMenu.setSelectedIndex(mode);
			modeMenuHandler(null);

			// used to stop fly_aways
			motors.auto_armed = (g.rc_3.control_in > 0);

			// clearing value used in interactive alt hold
			manual_boost = 0;

			// clearing value used to force the copter down in landing mode
			landing_boost = 0;
			reset_throttle_flag = false;

			// do we want to come to a stop or pass a WP?
			slow_wp = false;

			// do not auto_land if we are leaving RTL
			loiter_timer = 0;

			// if we change modes, we must clear landed flag
			land_complete 	= false;

			// have we acheived the proper altitude before RTL is enabled
			rtl_reached_alt = false;
			// debug to Serial terminal
			//Serial.println(flight_mode_strings[control_mode]);

			// report the GPS and Motor arming status
			led_mode = 0;

			switch(control_mode)
			{
				case ACRO:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_ACRO;
					throttle_mode 	= THROTTLE_MANUAL;
					break;

				case STABILIZE:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_STABLE;
					throttle_mode 	= THROTTLE_MANUAL;
					break;

				case ALT_HOLD:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_STABLE;
					throttle_mode 	= THROTTLE_HOLD;

					//force_new_altitude(Math.max(current_loc.alt, 100));
					force_new_altitude(Math.max(300, 100));
					break;

				case AUTO:
					yaw_mode 		= YAW_AUTO;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;

					// loads the commands from where we left off
					init_commands();
					break;

				case CIRCLE:
					yaw_mode 		= YAW_AUTO;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_HOLD;
					set_next_WP(current_loc);
					circle_WP		= next_WP.clone();
					circle_angle 	= 0;
					break;

				case LOITER:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_HOLD;
					set_next_WP(current_loc);
					//#if INERTIAL_NAV == ENABLED
					//zero_accels();
					//#endif
					break;

				case POSITION:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_MANUAL;
					set_next_WP(current_loc);
					break;

				case GUIDED:
					yaw_mode 		= YAW_AUTO;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					next_WP 		= current_loc;
					set_next_WP(guided_WP);
					break;

				case LAND:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					do_land();
					break;

				case RTL:
					yaw_mode 		= YAW_HOLD;
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					rtl_reached_alt = false;
					set_next_WP(current_loc);
					set_new_altitude(get_RTL_alt());
					break;

				/*case OF_LOITER:
					yaw_mode 		= OF_LOITER_YAW;
					roll_pitch_mode = OF_LOITER_RP;
					throttle_mode 	= OF_LOITER_THR;
					set_next_WP(current_loc);
					break;*/

				// THOR
				// These are the flight modes for Toy mode
				// See the defines for the enumerated values
				case TOY:
					yaw_mode 		= YAW_TOY;
					roll_pitch_mode = ROLL_PITCH_TOY;
					throttle_mode 	= THROTTLE_MANUAL;
					wp_control 		= NO_NAV_MODE;
					break;

				default:
					break;
			}

			if(failsafe){
				// this is to allow us to fly home without interactive throttle control
				throttle_mode = THROTTLE_AUTO;
				// does not wait for us to be in high throttle, since the
				// Receiver will be outputting low throttle
				motors.auto_armed = true;
			}

			// called to calculate gain for alt hold
			update_throttle_cruise();

			if(roll_pitch_mode <= ROLL_PITCH_ACRO){
				// We are under manual attitude control
				// remove the navigation from roll and pitch command
				reset_nav_params();
				// remove the wind compenstaion
				reset_wind_I();
				// Clears the alt hold compensation
				reset_throttle_I();
			}
		}

		public function set_failsafe(mode:Boolean):void
		{
			// only act on changes
			// -------------------
			if(failsafe != mode){

				// store the value so we don't trip the gate twice
				// -----------------------------------------------
				failsafe = mode;

				if (failsafe == false){
					// We've regained radio contact
					// ----------------------------
					failsafe_off_event();

				}else{
					// We've lost radio contact
					// ------------------------
					failsafe_on_event();
				}
			}
		}

		public function init_simple_bearing():void
		{
			initial_simple_bearing = ahrs.yaw_sensor;
		}

		public function update_throttle_cruise():void
		{
			var tmp:Number = g.pi_alt_hold.get_integrator();
			if(tmp != 0){
				g.throttle_cruise += tmp;
				reset_throttle_I();
			}
			// recalc kp
			//g.pid_throttle.kP(g.throttle_cruise.get() / 981.0);
			//Serial.printf("kp:%1.4f\n",kp);
		}

		// ----------------------------------------
		// SIM State
		// ----------------------------------------
		private function gainsHandler(e:Event):void
		{
			if(g.visible){
				g.visible = false;
				gains_button.setLabel("Show Gains");
			}else{
				g.visible = true;
				gains_button.setLabel("Hide Gains");
			}
		}

		private function graphHandler(e:Event):void
		{
			plotView.clearPlots();
			colorIndex = 0;
			plotMenuHandler(null);
			plot_A = plotView.addPlot("plot_A", 	getNewColor());
			plot_B = plotView.addPlot("plot_B", 	getNewColor());

			//stopSIM();
		}

		private function wpHandler(e:Event):void
		{
			wp_manager.visible = !wp_manager.visible;
			if(wp_manager.visible){
				waypoint_button.setLabel("Hide Waypoints");
			}else{
				waypoint_button.setLabel("Show Waypoints");
			}
		}

		private function joyHandler(e:Event):void
		{
			plotView.visible = !plotView.visible;
			if(plotView.visible){
				// hide joysticks
				left_sticks.visible = false;
				right_sticks.visible = false;
				joystick_button.setLabel("Show Joysticks");
			}else{
				// show joysticks
				left_sticks.visible = true;
				right_sticks.visible = true;
				joystick_button.setLabel("Show Graph");
			}
		}



		private function simHandler(e:Event):void
		{
			if(simIsRunnning == true){
				stopSIM();
			}else{
				startSIM();
			}
		}

		private function stopSIM():void
		{
			trace("---------------Stop sim---------------")
			trace("Alt Hold score:\t", alt_hold_score);
			trace("WP Nav score:\t", crosstrack_score);
			simIsRunnning = false;
			this.removeEventListener(Event.ENTER_FRAME, runSim);
			this.addEventListener(Event.ENTER_FRAME, idle);
			sim_controller.setLabel("START SIM");
			update_arm_label();
			init_disarm_motors();
			init_sim();
		}

		private function startSIM():void
		{
			trace("---------------Start sim---------------")
			sim_controller.setLabel("STOP SIM");
			simIsRunnning = true;
			g.updateGains();
			init_sim();
			user_settings_sim();
			init_ardupilot();
			air_start();
			// force a new state into the system for "Air Start"


			plotMenuHandler(null);
			plot_A = plotView.addPlot("plot_A", 	getNewColor());
			plot_B = plotView.addPlot("plot_B", 	getNewColor());
			this.removeEventListener(Event.ENTER_FRAME, idle);
			this.addEventListener(Event.ENTER_FRAME, runSim);


			// hide gains
			g.visible = false;
			gains_button.setLabel("Show Gains");
			sky.draw();
			ground.draw();
			//motors.armed = true;
		}

		private function init_ardupilot():void
		{
			init_wp();

			// radio
			init_rc_in();
			init_rc_out();
			default_dead_zones();
			// sets throttle to be at hovering setpoint
			left_sticks.knob_y.y = 0;

			// force sensors to new user defined location of the SIM copter
			baro.init();
			g_gps.init();

			// initialize commands
			// -------------------
			init_commands();

			// set the correct flight mode
			// ---------------------------
			reset_control_switch();

			startup_ground();

			trace("Ready to Fly")
		}

		private function startup_ground():void
		{
			// when we re-calibrate the gyros,
			// all previous I values are invalid
			reset_I_all();
		}


		private function air_start():void
		{
			// do this one time before we begin
			update_sim_radio();
			read_radio();

			init_arm_motors();

			// fix filters
			old_altitude		= copter.position.z;
			old_sonar_alt		= copter.position.z;
			old_baro_alt		= copter.position.z;
			baro_alt			= copter.position.z;

			// for a new home loc (0,0,0)
			// update GPS is missing this code
			init_home();

			// setup our next WP
			var nwp 			= new Location();
			nwp.lng 			= g.target_distance_BI.getNumber();
			nwp.lat 			= 0;
			nwp.alt 			= g.target_altitude_BI.getNumber();

			// force a new flight mode
			set_mode(modeMenu.getSelectedIndex());

			// force new WP after set_mode;
			set_next_WP(nwp);

			// hack to make the SIM go right into Land
			if(control_mode == LAND)
				do_land();


			// force out decent values to the motors
			apm_rc.outputCh(MOT_1, g.throttle_cruise + 1000);
			apm_rc.outputCh(MOT_2, g.throttle_cruise + 1000);
			apm_rc.outputCh(MOT_3, g.throttle_cruise + 1000);
			apm_rc.outputCh(MOT_4, g.throttle_cruise + 1000);
			g.rc_3.servo_out = g.throttle_cruise;
		}


		private function user_settings_sim():void
		{
			// Attitude
			ahrs.dcm.appendRotation(g.start_angle_BI.getNumber(), 	Vector3D.X_AXIS);	// ROLL
			ahrs.dcm.appendRotation(0, 	Vector3D.Y_AXIS);	// PITCH
			ahrs.dcm.appendRotation(0, 	Vector3D.Z_AXIS);	// Yaw

			// rotation speed
			ahrs.gyro.x	= g.start_rotation_BI.getNumber();
			ahrs.gyro.y	= 0;
			ahrs.gyro.z	= 0;

			// Velocity
			copter.velocity.x	= g.start_speed_BI.getNumber();
			copter.velocity.y	= 0;
			copter.velocity.z	= g.start_climb_rate_BI.getNumber();

			accels_velocity.x	= copter.velocity.x;
			accels_velocity.y	= copter.velocity.y;
			accels_velocity.z	= copter.velocity.z;

			// Position
			copter.position.x 	= g.start_position_BI.getNumber();
			copter.position.y 	= 0;
			copter.position.z 	= g.start_height_BI.getNumber(); // add in some delay

			accels_position.x	= copter.position.x;
			accels_position.y	= copter.position.y;
			accels_position.z	= copter.position.z;

			copter.loc.lng 		= copter.position.x;
			copter.loc.lat 		= copter.position.y;
			copter.loc.alt 		= copter.position.z;

			current_loc.lng		= copter.position.x;
			current_loc.lat		= copter.position.y;
			current_loc.alt		= copter.position.z;
			last_longitude		= current_loc.lng;
			last_latitude		= current_loc.lat;


			offset_x_gain		= g.xy_offset_correction;
			offset_y_gain		= g.xy_offset_correction;
			offset_z_gain		= g.z_offset_correction;

			baro.enable_noise	= g.baro_noise_checkbox.getSelected();
			fastPlot			= g.fastPlot_checkbox.getSelected();


			// Setup Wind
			if(g.wind_checkbox.getSelected()){
				copter.windGenerator.setDirection(g.windDir_BI.getNumber());
				copter.windGenerator.setSpeed(g.wind_low_BI.getNumber(), g.wind_high_BI.getNumber());
				copter.windGenerator.setPeriod(g.wind_period_BI.getNumber()*1000);
			}else{
				copter.windGenerator.setSpeed(0, 0);
			}

			g.rc_3.servo_out 	= g.rc_3.control_in;
		}

		private function init_wp():void
		{
			// ------------------------------------------------------
			// Setup waypoints
			// ------------------------------------------------------

			/*
			// The Baseball fields at GGPark
			wp_manager.lat_offset = 377679650;
			wp_manager.lng_offset = -1224646780;
			wp_manager.addWaypoint(22, 1, 0, 600, 377679648, -1224646784);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377679648, -1224646784);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377672224, -1224645760);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377678272, -1224646656);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377679712, -1224639616);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377677344, -1224652288);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377679200, -1224646656);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377672960, -1224645120);
			wp_manager.addWaypoint(16, 1, 0, 1200, 377672896, -1224649472);
			wp_manager.addWaypoint(16, 1, 0, 500, 377679168, -1224646656);
			wp_manager.addWaypoint(MAV_CMD_NAV_LAND, 1, 0, 0, 0, 0);
			*/

			/*
			// A Basic 40m square for testing
			wp_manager.clearWaypoints();
			wp_manager.addWaypoint(22, 1, 0, 1200, 0, 0);
			wp_manager.addWaypoint(16, 1, 0, 1200, 4000, 0);
			wp_manager.addWaypoint(16, 1, 0, 1200, 4000, 4000);
			wp_manager.addWaypoint(16, 1, 0, 1200, 0, 4000);
			wp_manager.addWaypoint(16, 1, 0, 1200, 0, 0);
			wp_manager.addWaypoint(MAV_CMD_NAV_LAND, 1, 0, 0, 0, 0);
			*/

			// The Baseball fields at GGPark, monocole interview
			/*
			wp_manager.clearWaypoints();
			wp_manager.lat_offset = 377679251;
			wp_manager.lng_offset = -1224646698;
			wp_manager.addWaypoint(22, 0, 0, 251, 377679251, -1224646698);
			wp_manager.addWaypoint(16, 0, 0, 251, 377679251, -1224646698);
			wp_manager.addWaypoint(16, 0, 0, 535, 377674240, -1224646056);
			wp_manager.addWaypoint(16, 0, 0, 749, 377678506, -1224646730);//
			wp_manager.addWaypoint(16, 0, 0, 647, 377680200, -1224641799);
			wp_manager.addWaypoint(16, 0, 0, 720, 377678907, -1224648277);
			wp_manager.addWaypoint(16, 0, 0, 375, 377678559, -1224646056);
			wp_manager.addWaypoint(21, 0, 0, -265, 377678411, -1224645601);
			*/

			//Tilt test
			wp_manager.clearWaypoints();
			wp_manager.lat_offset =  	0; //y
			wp_manager.lng_offset =    	0; // x
			wp_manager.addWaypoint(22, 0, 0, 	1000, 0, 0);				// 1 takeoff to 10m
			wp_manager.addWaypoint(16, 0, 10, 	1000, 1000, 	-1000); 	// 2 go to this wp, wait 30 seconds
			wp_manager.addWaypoint(18, 0, 2, 	1000, 	1,  		1);		// 3 go to this wp, circle twice
			//CMD, 8, 3, 18, 0, 2, 1000, 1, 1

								//     op p1   alt    lat          lng
			wp_manager.addWaypoint(19, 0, 0, 	1000,  1000,  		1);		// 4 go to this wp, Loiter 10 s
			wp_manager.addWaypoint(16, 0, 0, 	1000,  0, 			0);		// 5 go to this wp
			//wp_manager.addWaypoint(16, 0, 0, 1000, 2000, 2000);			//  go to this wp
			wp_manager.addWaypoint(115, 0, 1, 720, 45, 1);					// 6 do condition yaw angle: speed, direction (-1,1), rel (1), abs (0),
			//wp_manager.addWaypoint(16, 0, 0, 1000, 1, 1);
			wp_manager.addWaypoint(20, 0, 0, 0, 0, 0);						// 7 RTL
			//wp_manager.update();

			// AP Command enumeration
			/*
			public const MAV_CMD_NAV_WAYPOINT			:int = 16;
			public const MAV_CMD_NAV_LOITER_UNLIM		:int = 17;
			public const MAV_CMD_NAV_LOITER_TURNS		:int = 18;
			public const MAV_CMD_NAV_LOITER_TIME		:int = 19;
			public const MAV_CMD_NAV_RETURN_TO_LAUNCH	:int = 20;
			public const MAV_CMD_NAV_LAND				:int = 21;
			public const MAV_CMD_NAV_TAKEOFF			:int = 22;
			public const MAV_CMD_NAV_LAST				:int = 95;

			public const MAV_CMD_CONDITION_DELAY		:int = 112;
			public const MAV_CMD_CONDITION_DISTANCE		:int = 114;
			public const MAV_CMD_CONDITION_CHANGE_ALT	:int = 113;
			public const MAV_CMD_CONDITION_YAW			:int = 115;
			public const MAV_CMD_CONDITION_LAST			:int = 159;

			public const MAV_CMD_DO_JUMP				:int = 177;
			public const MAV_CMD_DO_CHANGE_SPEED		:int = 178;
			public const MAV_CMD_DO_SET_HOME			:int = 179;
			public const MAV_CMD_DO_SET_SERVO			:int = 183;
			public const MAV_CMD_DO_SET_RELAY			:int = 181;
			public const MAV_CMD_DO_REPEAT_SERVO		:int = 184;
			public const MAV_CMD_DO_REPEAT_RELAY		:int = 182;
			public const MAV_CMD_DO_SET_ROI				:int = 201;

			public const MAV_ROI_NONE					:int = 0;
			public const MAV_ROI_WPNEXT					:int = 1;
			public const MAV_ROI_WPINDEX				:int = 2;
			public const MAV_ROI_LOCATION				:int = 3;
			public const MAV_ROI_TARGET					:int = 4;
			public const MAV_ROI_ENUM_END				:int = 5;
			*/
		}

		private function init_sim():void
		{
			// initialize all internal values to default state
			copter.init();
			ahrs.init();
			user.init();
			copter.windGenerator.resetWind();

			copter.setThrottleCruise(g.THROTTLE_CRUISE);
			g.throttle_cruise 	= g.THROTTLE_CRUISE + g.throttle_cruise_e;

			home				= new Location();
			prev_WP				= new Location();
			target_WP			= new Location();
			guided_WP			= new Location();
			command_cond_queue	= new Location();
			command_nav_queue	= new Location();
			current_loc			= new Location();
			sky.current_loc 	= this.current_loc; // Pass a reference to Sky

			// --------------------------------------
			// Timers
			// --------------------------------------
			iteration 						= 0;
			elapsed							= 0;
			medium_loop_counter				= 0;
			fifty_toggle					= false;
			medium_loopCounter				= 0;
			slow_loopCounter				= 0;
			superslow_loopCounter			= 0;
			auto_disarming_counter			= 0;
			last_gps_time					= 0;
			counter_one_herz				= 0;
			gps_watchdog					= 0;
			crosstrack_score				= 0;
			alt_hold_score					= 0;
			home_is_set						= false;
			alt_sensor_flag					= false;
			low_batt						= false;
			GPS_enabled						= true;
			event_undo_value				= 0;
			event_id						= 0;

			// -----------------------------------------
			// Flight Modes
			// -----------------------------------------
			roll_pitch_mode					= 0;
			yaw_mode						= 0;
			throttle_mode					= 0;
			throttle_avg					= 0;
			takeoff_complete				= false;
			circle_angle					= 0;
			loiter_total					= 0;
			loiter_sum						= 0;
			loiter_time						= 0;
			loiter_time_max					= 0;

			toy_alt_hold					= false;
			sky.toy_alt_hold_MC.visible		= false;

			// -----------------------------------------
			// Simple Mode
			// -----------------------------------------
			do_simple						= false;
			oldSwitchPosition				= 0;
			initial_simple_bearing			= 0;
			simple_counter					= 0;
			trim_flag						= false;
			CH7_wp_index					= 0;

			// -----------------------------------------
			// Climb rate control
			// -----------------------------------------
			original_altitude				= 0;
			target_altitude					= 0;
			alt_change_timer				= 0;
			alt_change_flag					= 0;
			alt_change						= 0;

			nav_thrust_z					= 0;
			d_alt_accel						= 0;
			z_boost							= 0;
			rtl_reached_alt					= false;
			// -----------------------------------------
			// Loiter and NAV
			// -----------------------------------------
			desired_speed					= 0;
			p_loiter_rate					= 0;
			i_loiter_rate					= 0;
			d_loiter_rate					= 0;
			p_nav_rate						= 0;
			i_nav_rate						= 0;
			d_nav_rate						= 0;
			nav_lon							= 0;
			nav_lat							= 0;
			nav_roll						= 0;
			nav_pitch						= 0;
			last_longitude					= 0;
			last_latitude					= 0;
			lon_filter 						= new AverageFilter(g.speed_filter_size);
			xLeadFilter.init();
			yLeadFilter.init();
			nav_ok							= false;
			auto_roll						= 0;
			auto_pitch						= 0;
			slow_wp							= false;
			loiter_timer					= 0;
			wp_control						= 0;
			wp_verify_byte					= 0;
			loiter_override					= false;
			crosstrack_error				= 0;
			long_error						= 0;
			lat_error						= 0;
			baro_rate						= 0;
			sonar_rate						= 0;
			sonar_alt						= 0;
			old_sonar_alt					= 0;
			wp_distance						= 0;
			home_distance					= 0;
			home_to_copter_bearing			= 0;
			target_bearing					= 0;
			old_target_bearing				= 0;
			original_target_bearing			= 0;
			jump							= -10;
			command_cond_index				= 0;
			prev_nav_index					= 0;
			command_nav_index				= 0;
			condition_value					= 0;
			condition_start					= 0;
			nav_yaw							= 0;
			auto_yaw						= 0;
			yaw_tracking 					= 1; 		//MAV_ROI_WPNEXT;
			command_yaw_start				= 0;
			command_yaw_start_time			= 0;
			command_yaw_time				= 0;
			command_yaw_end					= 0;
			command_yaw_delta				= 0;
			command_yaw_speed				= 0;
			command_yaw_dir					= 0;
			command_yaw_relative			= 0;
			cos_roll_x						= 1;
			cos_pitch_x						= 1;
			cos_yaw_x						= 1;
			sin_yaw_y						= 0;

			// -----------------------------------------
			// GPS Latency patch
			// -----------------------------------------
			speed_old						= 0;
			failsafeCounter					= 0;

			// -----------------------------------------
			// Acro
			// -----------------------------------------
			roll_axis						= 0;
			pitch_axis						= 0;
			do_flip							= false;
			flip_timer						= 0;
			flip_state 						= 0;

			// -----------------------------------------
			// Stabilize
			// -----------------------------------------
			p_stab							= 0;
			i_stab							= 0;
			p_stab_rate						= 0;
			i_stab_rate						= 0;
			d_stab_rate						= 0;
			roll_rate_error					= 0;
			pitch_rate_error				= 0;
			roll_last_rate					= 0;
			pitch_last_rate					= 0;
			roll_servo_out					= 0;
			pitch_servo_out					= 0;
			roll_rate_d_filter.init();
			pitch_rate_d_filter.init();
			roll_scale_d					= 0;
			pitch_scale_d					= 0;

			rate_d_dampener					= 0;
			control_roll					= 0;
			control_pitch					= 0;

			// -----------------------------------------
			// Altitude hold
			// -----------------------------------------
			angle_boost						= 0;
			manual_boost					= 0;
			nav_throttle					= 0;
			z_target_speed					= 0;
			i_hold							= 0;
			p_alt_rate						= 0;
			i_alt_rate						= 0;
			d_alt_rate						= 0;
			z_rate_error					= 0;

			last_error						= 0;
			throttle						= 0;
			err								= 0;
			altitude_error					= 0;
			old_altitude					= 0;
			old_alt							= 0;
			reset_throttle_flag				= false;

			climb_rate						= 0;
			climb_rate_actual				= 0;
			climb_rate_error				= 0;
			landing_boost					= 0;
			land_complete					= false;
			ground_detector					= 0;

			// Inertia
			//accels_scale.x					= 0;
			//accels_scale.y					= 0;
			//accels_scale.z					= 0;
			accels_position.x				= 0;
			accels_position.y				= 0;
			accels_position.z				= 0;
			accels_velocity.x				= 0;
			accels_velocity.y				= 0;
			accels_velocity.z				= 0;

			reset_I_all();
			reset_nav_params();

			// Copter state
			failsafe 			= false;
			failsafeCounter		= 0;
			radio_failure 		= false;
		}


		public function update_sim_radio():void
		{
			//
			//read out rc_throttle and rc_roll

			if(radio_failure){
				ch_3_pwm = 900;
			}else{
				ch_1_pwm = right_sticks.pwm_x;
				ch_2_pwm = right_sticks.pwm_y;
				ch_3_pwm = 3000 - left_sticks.pwm_y; // reversed
				ch_4_pwm = left_sticks.pwm_x;
			}

			apm_rc.set_PWM_channel(ch_1_pwm,	 	CH_1);
			apm_rc.set_PWM_channel(ch_2_pwm, 		CH_2);
			apm_rc.set_PWM_channel(ch_3_pwm,	 	CH_3);
			apm_rc.set_PWM_channel(ch_4_pwm, 		CH_4);
			apm_rc.set_PWM_channel(ch_5_pwm, 		CH_5);
			apm_rc.set_PWM_channel(ch_6_pwm, 		CH_6);
			apm_rc.set_PWM_channel(ch_7_pwm, 		CH_7);
			//apm_rc.set_PWM_channel(ch_8_pwm, 		CH_8); // not used
		}

		// -----------------------------------------------------------------------------------
		// GUI Handlers
		//------------------------------------------------------------------------------------
		private function keyDownHandler(k:KeyboardEvent):void
		{
			switch(k.keyCode){
				case 118:  // F7 or channel 7
					ch_7_pwm = 1900;
					break;
			}

		}

		private function keyUpHandler(k:KeyboardEvent):void
		{
			//trace(k.keyCode);

			if(k.shiftKey){
				switch(k.keyCode){
					// --------------------------------------------------------------------------
					// Flight modes
					// --------------------------------------------------------------------------
					case 48: // 0
						set_mode(STABILIZE);
						break;
					case 49: // 1
						set_mode(ACRO);
						break;
					case 50: // 2
						set_mode(ALT_HOLD);
						break;
					case 51: // 3
						set_mode(AUTO);
						break;
					case 52: // 4
						set_mode(GUIDED);
						break;
					case 53: // 5
						set_mode(LOITER);
						break;
					case 54: // 6
						set_mode(RTL);
						break;
					case 55: // 7
						set_mode(CIRCLE);
						break;
					case 56: // 8
						set_mode(POSITION);
						break;
					case 57: // 9
						set_mode(LAND);
						break;

					// --------------------------------------------------------------------------
					// Plot control
					// --------------------------------------------------------------------------
					case 38: // Up
						plotView.setScale(plotView.dataScaleX, (plotView.dataScaleY + .01))
						break;
					case 40: // Down
						plotView.setScale(plotView.dataScaleX, (plotView.dataScaleY -.01))
						break;
					case 37: // Left
						plotView.setScale((plotView.dataScaleX/2), plotView.dataScaleY)
						break;
					case 39: // Right
						plotView.setScale((plotView.dataScaleX*2), plotView.dataScaleY)
						break;
				}
			}

			switch(k.keyCode){
				case 66:  // b
					copter.jump();
					break;

				case 84:  // 1 for
					test_radio_rage_output();
					break;

				case Keyboard.SPACE:
					gainsHandler(null);
					break;

				case 87:  // w for waypoint dump
					report_wp();
					break;

				case 118:  // F7 or channel 7
					ch_7_pwm = 1200;
					break;

				case 70: // f for fail
					radio_failure = !radio_failure
					trace("RC Failure");
					break;

				case 83: // s for start/stop
					simHandler(null);
					break;

				case 72: // h for hover
					//rc_throttle.knob.x = 0;
					left_sticks.knob_y.y = 0;

					break;

				case 76: // l for loop
					init_flip();
					break;

				case 65: // q for up NextWP by 100
					toy_alt_hold = !toy_alt_hold;
					force_new_altitude(current_loc.alt);
					break;

				case 81: // q for up NextWP by 100
					//next_WP.alt += 100;
					if(toy_alt == -1)
						toy_alt = current_loc.alt
					if(current_loc.alt > 300){
						toy_alt += 100;
					}else{
						toy_alt += 25;
					}
					//toy_alt = Math.max(toy_alt, 200);
					toy_alt = Math.min(toy_alt, 3000);
					force_new_altitude(toy_alt);
					break;

				case 90: // z for downp NextWP by 100
					if(toy_alt == -1)
						toy_alt = current_loc.alt
					if(current_loc.alt > 300){
						toy_alt -= 100;

					}else{
						toy_alt -= 25;

					}

					//toy_alt = Math.max(toy_alt, 200);
					force_new_altitude(toy_alt);
					//next_WP.alt -= 100;
					//next_WP.alt = Math.max(next_WP.alt, 100);
					break;

			}
		}

		private function plotMenuHandler(e:Event):void
		{
			var item:QuickMenuItem;
			item = plotMenu.getSelectedItem();
			this.plotType_A = item.getCode();
			plotMenu.setLabel(item.getLabel());

			item = plotMenu2.getSelectedItem();
			this.plotType_B = item.getCode();
			plotMenu2.setLabel(item.getLabel());
		}

		private function modeMenuHandler(e:Event):void
		{
			var item:QuickMenuItem = modeMenu.getSelectedItem();
			modeMenu.setLabel(item.getLabel());
			if(e != null)
				radio_switch_position = modeMenu.getSelectedIndex();
			//set_mode(modeMenu.getSelectedIndex());
		}

		private function armHandler(e:Event):void
		{
			motors.armed = !motors.armed;
			update_arm_label();
		}

		private function update_arm_label():void
		{
			//trace("motors.armed", motors.armed);

			if(motors.armed)
				arm_button.setLabel("Motors Armed");
			else
				arm_button.setLabel("Motors Disarmed");
		}
		// -----------------------------------------------------------------------------------
		// Plotting
		//------------------------------------------------------------------------------------

		private function plot(ptype:String, plot_num:int, plot_label:int):void
		{
			var val		:Number = 0;
			var _scale	:Number = 1;

			switch (ptype)
			{
				// stabilze
				case "roll_sensor":
					val = ahrs.roll_sensor;
					_scale = .1;
				break;

				case "pitch_sensor":
					val = ahrs.pitch_sensor;
					_scale = .1;
				break;
				case "control_roll":
					val = control_roll;
				break;



				case "roll_error":
					val = (control_roll - ahrs.roll_sensor);
				break;

				case "stab_p":
					val = p_stab;
				break;
				case "stab_i":
					val = i_stab;
				break;


				case "roll_rate_error": // roll rate error
					val = roll_rate_error;
				break;
				case "rate_p":
					val = p_stab_rate;
				break;
				case "rate_i":
					val = i_stab_rate;
				break;
				case "rate_d":
					val = d_stab_rate;
				break;
				case "rate_damp":
					val = rate_d_dampener;
				break;
				case "roll_output":
					val = roll_output;
				break;

				case "yaw_i":
					_scale = .1;
					val = g.pi_stabilize_yaw.get_integrator();
				break;
				case "rate_yaw_i":
					_scale = .1;
					val = g.pid_rate_yaw.get_integrator();
				break;
				case "yaw_out":
					_scale = .1;
					val = yaw_output;
				break;


				case "wp_distance":
					_scale = .1;
					val = wp_distance;
				break;

				case "long_error":
					val = long_error;
				break;

				case "lat_error":
					val = lat_error;
				break;

				case "x_speed":
					val = x_actual_speed;
				break;

				case "x_target_speed":
					val = x_target_speed;
				break;

				case "x_rate_error":
					val = x_rate_error;
				break;

				case "y_speed":
					val = y_actual_speed;
				break;

				case "y_target_speed":
					val = y_target_speed;
				break;

				case "y_rate_error":
					val = y_rate_error;
				break;


				case "nav_lon":
					_scale = .1;
					val = nav_lon;
				break;

				case "nav_lat":
					_scale = .1;
					val = nav_lat;
				break;

				case "ground_speed":
					val = g_gps.ground_speed;
				break;



				case "loiter_rate_p":
					val = p_loiter_rate;
				break;

				case "loiter_rate_i":
					val = i_loiter_rate;
				break;

				case "loiter_rate_d":
					val = d_loiter_rate;
				break;


				case "nav_lon_rate_p":
					val = p_nav_rate;
				break;

				case "nav_lon_rate_i":
					val = i_nav_rate;
				break;

				case "nav_lon_rate_d":
					val = d_nav_rate;
				break;

				case "nav_lat_rate_i":
					val = g.pid_nav_lat.get_integrator();
				break;

				case "altitude":
					val = current_loc.alt;
				break;
				case "next_wp_alt":
					val = next_WP.alt;
				break;

				case "altitude_error":
					val = altitude_error;
				break;

				case "act_altitude_error":
					val = (next_WP.alt - copter.loc.alt);
					_scale = .01;
				break;

				case "z_target_speed":
					val = z_target_speed;
				break;

				case "alt_hold_i":
					val = i_hold;
					_scale = 10;

				break;


				case "z_rate_error":
					val = z_rate_error;
				break;

				case "alt_rate_p":
					val = p_alt_rate;
				break;

				case "alt_rate_i":
					val = i_alt_rate;
					_scale = 10;
				break;

				case "alt_rate_d":
					val = d_alt_rate;
				break;

				case "d_alt_accel":
					val = d_alt_accel;
					_scale = 100;
				break;

				//case "accel_x":
				//	val = ahrs.accel.x
				//	_scale = 100;
				//break;

				//case "vel_x":
				//	val = accels_velocity.x
					//_scale = 1;
				//break;


				//case "accel_z":
				//	val = ahrs.accel.z;
				//	_scale = 100;
				//break;

				case "vel_x":
					val = speed_error.x
					//_scale = 1;
				break;

				case "pos_x":
					//val = position_error.x
					//_scale = 1;
				break;

				case "off_x":
					//val = accels_scale.x
					//_scale = 100;
				break;

				case "vel_z":
					val = speed_error.z
					//_scale = 1;
				break;

				case "pos_z":
					//val = position_error.z
					//_scale = 1;
				break;

				case "off_z":
					//val = accels_scale.z
					//_scale = 100;
				break;

				case "off_z":
					val = offset_z_gain * 10000
					_scale = 1;
				break;



				//case "z_boost":
			//		val = z_boost;
					//_scale = 100;
			//	break;


				case "angle_boost":
					val = angle_boost;
				break;


				case "throttle_cruise":
					val = g.throttle_cruise;
				break;

				case "throttle_out":
					val = g.rc_3.servo_out;
				break;

				/*case "motor_1":
					val = motor_out[MOT_1] - 1000;
				break;

				case "motor_2":
					val = motor_out[MOT_2] - 1000;
				break;
				*/

				case "wind_speed":
					val = copter.wind.x;
				break;

				case "yaw_sensor":
					_scale = .01;
					val = ahrs.yaw_sensor;
				break;

				case "t_angle_err":
					_scale = .01;
					val = target_bearing - original_target_bearing;
				break;
				case "t_angle":
					_scale = .01;
					val = target_bearing;
				break;
				case "crosstrack_error":
					//_scale = .01;
					val = crosstrack_error;
				break;



				default:
					val = 0;
				//no case tested true;
			}

			plotView.setValue(val,	plot_num, _scale);

			if(plot_label == 1)
				plot_TF.text = val.toFixed(2);
			else
				plot2_TF.text = val.toFixed(2);
		}

		// -----------------------------------------------------------------------------------
		// Utility functions
		//------------------------------------------------------------------------------------

		public function test_radio_rage_input(index:int = 255)
		{
			ch_6_pwm = 990;
			g.rc_6.set_dead_zone(60);
			g.rc_6.set_range(1000,2000);
			trace("----------------------------")
			trace(g.rc_6._high_in, g.rc_6._high_in);
			trace("----------------------------")

			for (var i:int = 0; i < 1020; i++){
				apm_rc.set_PWM_channel(ch_6_pwm, CH_6);
				g.rc_6.set_pwm(apm_rc.InputCh(CH_6));
				ch_6_pwm++;
				trace(g.rc_6.radio_in, g.rc_6.control_in);
			}
		}

		public function test_radio_rage_output(index:int = 255)
		{
			g.rc_3.set_range(g.throttle_min, g.throttle_max);
			g.rc_3.set_range_out(0, 1000);
			g.rc_3.set_dead_zone(60);
			var s_out:int = 0;

			trace("----------------------------")
			trace(g.rc_3._high_out, g.rc_3._low_out);
			trace("----------------------------")

			for (s_out = 0; s_out < 1000; s_out++){
				//apm_rc.set_PWM_channel(ch_3_pwm, CH_3);
				//g.rc_3.set_pwm(apm_rc.InputCh(CH_3));

				g.rc_3.servo_out = s_out;
				g.rc_3.calc_pwm();
				trace("servo_out:", s_out, Math.floor(g.rc_3.pwm_out), Math.floor(g.rc_3.radio_out));
			}
		}

		public function report_wp(index:int = 255)
		{
			var temp:Location;
			if(index == 255){
				for(var i:int = 0; i < g.command_total; i++){
					temp = get_cmd_with_index(i);
					print_wp(temp, i);
				}
			}else{
				temp = get_cmd_with_index(index);
				print_wp(temp, index);
			}
		}

		public function print_wp(cmd:Location, index:int)
		{
			trace("WP, " + index + " id:" + cmd.id + " op:" + cmd.options + " p1:" + cmd.p1 + " p2:" + cmd.alt + " p3:" + cmd.lat + " p4:" + cmd.lng);
			//trace("CMD, " + index + ", " + cmd.id + ", " + cmd.options + ", " + cmd.p1 + ", " + cmd.alt + ", " + cmd.lat + ", " + cmd.lng);
		}

		public static function formatTime(time:Number):String
		{
			time /=1000;
			var remainder:Number;

			var hours:Number = time / ( 60 * 60 );

			remainder = hours - (Math.floor ( hours ));

			hours = Math.floor ( hours );

			var minutes = remainder * 60;

			remainder = minutes - (Math.floor ( minutes ));

			minutes = Math.floor ( minutes );

			var seconds = remainder * 60;

			remainder = seconds - (Math.floor ( seconds ));

			seconds = Math.floor ( seconds );

			var hString:String = hours < 10 ? "0" + hours : "" + hours;
			var mString:String = minutes < 10 ? "0" + minutes : "" + minutes;
			var sString:String = seconds < 10 ? "0" + seconds : "" + seconds;

			if ( time < 0 || isNaN(time)) return "00:00";

			if ( hours > 0 )
			{
				return hString + ":" + mString + ":" + sString;
			}else{
				return mString + ":" + sString;
			}
		}

		public function constrain(val:Number, min:Number, max:Number):Number
		{
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

		public function radians(n:Number):Number
		{
			return 0.0174532925 * n;
		}

		public function radiansx100(n:Number):Number
		{
			return 0.000174532925 * n;
		}

		public function degrees(radians:Number):Number
		{
			return radians * 180/Math.PI
		}

		public function wrap_360(error:int):int
		{
			if (error > 36000)	error -= 36000;
			if (error < 0)		error += 36000;
			return error;
		}

		public function getNewColor():Number
		{
			colorIndex++;
			if (colorIndex >= colors.length)
				colorIndex = 0;
			return colors[colorIndex];

			//Math.floor(Math.random() * 0xFFFFFF);
		}

		public function millis():int
		{
			return elapsed;
		}
		public function delay(n:int)
		{
			elapsed += n;
		}
	}
}

