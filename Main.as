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


	public class Main extends MovieClip
	{
		// --------------------------------------
		// SIM and Data
		// --------------------------------------
		public var g								:Parameters;
		public var simIsRunnning					:Boolean = false;
		public var iteration						:int = 0;
		public var copter							:Copter;
		public var ghost							:MovieClip;
		public var copter_lag						:MovieClip;
		public var ahrs								:AHRS;
		public var relay							:Relay;
		public var apm_rc							:APM_RC;
		public var motor_rpm						:Number = 0;
		public var motor_pwm						:Number = 0;
		public var failsafe							:Boolean = false;
		public var radio_failure					:Boolean = false;

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
		public const APPROACH						:int = 11;

		public const LOITER_MODE					:int = 1;
		public const WP_MODE						:int = 2;
		public const CIRCLE_MODE					:int = 3;
		public const NO_NAV_MODE					:int = 4;


		public const YAW_HOLD 						:int = 0;
		public const YAW_ACRO 						:int = 1;
		public const YAW_AUTO 						:int = 2;
		public const YAW_LOOK_AT_HOME 				:int = 3;

		public const ROLL_PITCH_STABLE				:int = 0;
		public const ROLL_PITCH_ACRO				:int = 1;
		public const ROLL_PITCH_AUTO				:int = 2;
		public const ROLL_PITCH_STABLE_OF			:int = 3;

		public const THROTTLE_MANUAL				:int = 0;
		public const THROTTLE_HOLD					:int = 1;
		public const THROTTLE_AUTO					:int = 2;

		public const ASCENDING						:int = 1;
		public const DESCENDING						:int = -1;
		public const REACHED_ALT					:int = 0;
		public const MINIMUM_THROTTLE				:int = 130;
		public const MAXIMUM_THROTTLE				:int = 850;
		public const RTL_APPROACH_DELAY				:int = 20;
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


		public var flight_mode_strings				:Array;




		// --------------------------------------
		// Timers
		// --------------------------------------
		public var dTnav							:Number = 0.25;
		public var G_Dt								:Number = 0.01;
		public var m_dt								:Number = 0.02;
		public var elapsed							:int = 0;
		private var medium_loop_counter				:int = 0;
		private var gps_counter						:int = 0;
		private var fifty_toggle					:Boolean = false;
		private var medium_loopCounter				:int = 0;
		private var slow_loopCounter				:int = 0;
		private var superslow_loopCounter			:int = 0;
		private var auto_disarming_counter			:int = 0;
		private var counter_one_herz				:int = 0;


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

		// --------------------------------------
		// Telemetry and Sensors
		// --------------------------------------
		public var g_gps							:GPS;
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

		// -----------------------------------------
		// Simple Mode
		// -----------------------------------------
		public var do_simple						:Boolean = false;
		public var oldSwitchPosition				:int = 0;
		public var initial_simple_bearing			:int = 0;
		public var simple_counter					:int = 0;
		public var trim_flag						:Boolean = false;
		public var CH7_wp_index						:int = 0;


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

		// -----------------------------------------
		// Loiter and NAV
		// -----------------------------------------
		public var desired_speed					:Number = 0;
		public var x_actual_speed					:Number = 0;
		public var x_target_speed					:Number = 0;
		public var p_loiter_rate					:Number = 0;
		public var i_loiter_rate					:Number = 0;
		public var d_loiter_rate					:Number = 0;

		public var p_nav_rate						:Number = 0;
		public var i_nav_rate						:Number = 0;
		public var d_nav_rate						:Number = 0;

		public var nav_lon							:Number = 0;
		public var nav_roll							:Number = 0;

		public var x_rate_error						:Number = 0;

		private var last_longitude					:Number	= 0;

		public var lon_filter						:AverageFilter;
		private var nav_ok							:Boolean = false;
		public var auto_roll						:Number = 0;
		public var slow_wp							:Boolean = false;
		public var waypoint_speed_gov				:int;
		public var loiter_timer						:int = 0;
		public var wp_control						:int = 0;
		public var wp_verify_byte					:int = 0;
		public var loiter_override					:Boolean = false;
		public var crosstrack_error					:Number = 0;
		public var last_ground_speed				:Number = 0;
		public var long_error						:Number = 0;
		public var long_error_old					:Number = 0;
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
		public var nav_bearing						:Number = 0;
		public var jump								:int = -10;
		public var command_cond_index				:int = 0;
		public var prev_nav_index					:int = 0;
		public var command_nav_index				:int = 0;


		public var condition_value					:Number = 0;
		public var condition_start					:Number = 0;


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

		public var cos_roll_x						:Number = 0;
		public var cos_pitch_x						:Number = 0;

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

		public var roll_last_rate					:Number = 0;
		public var roll_servo_out					:Number = 0;
		public var roll_rate_d_filter				:AverageFilter;
		public var roll_scale_d						:Number = 0;

		public var rate_d_dampener					:Number = 0;
		public var control_roll						:Number = 0;
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
		public var target							:Number = 500;
		public var throttle_min						:Number = 0;
		public var reset_throttle_flag				:Boolean = false;

		public var climb_rate						:Number = 0;
		public var climb_rate_actual				:Number = 0;
		public var climb_rate_error					:Number = 0;
		public var landing_boost					:Number = 0;
		public var land_complete					:Boolean = false;
		public var ground_detector					:int = 0;

		public function Main():void
		{
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
			sensor_speed			= new Vector3D;
			lon_filter				= new AverageFilter(g.speed_filter_size);
			roll_rate_d_filter		= new AverageFilter(3);
			motors					= new Motors();
			waypoints				= new Array();
			motor_out				= new Array();

			copter.ahrs				= ahrs;
			copter.apm_rc			= apm_rc;

			// AP queues
			command_nav_queue 		= new Location();
			command_cond_queue 		= new Location();


			sky.addChild(copter);
			sky.addChild(ghost);
			sky.addChild(copter_lag);

			//sky.s = next_WP;
			sky.copter 		= copter;
			sky.ghost 		= ghost;
			sky.copter_lag 	= copter_lag;
			sky.controller 	= this;
			sky.current_loc = this.current_loc;

			flight_mode_strings = new Array("STABILIZE","ACRO","ALT_HOLD","AUTO","GUIDED","LOITER","RTL","CIRCLE","POSITION","LAND","OF_LOITER");
			colors = new Array(0xD6C274, 0xDB9E46, 0x95706B, 0x9D2423, 0xAB362E, 0xB5BC37, 0x7EBC5F, 0x74287D, 0x765A70, 0xA82DBC, 0xD9B64E, 0xF28B50, 0xF25E3D, 0x79735E, 0x6D78F4);
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
			modeMenu.addItem(new QuickMenuItem("11 APPROACH",	"11"));

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	    }


	    public function populateMenus(m:QuickPopupMenu):void
		{
			// Stability
			m.addItem(new QuickMenuItem("Roll Sensor",			"roll_sensor"));
			m.addItem(new QuickMenuItem("Desired Roll",			"control_roll"));

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
			m.addItem(new QuickMenuItem("Actual Speed", 		"speed"));
			m.addItem(new QuickMenuItem("Desired Speed",		"x_target_speed"));
			m.addItem(new QuickMenuItem("Rate Error", 			"x_rate_error"));
			m.addDivider(new QuickMenuDivider());

			// Loiter
			m.addItem(new QuickMenuItem("Loiter Rate P", 		"loiter_rate_p"));
			m.addItem(new QuickMenuItem("Loiter Rate I", 		"loiter_rate_i"));
			m.addItem(new QuickMenuItem("Loiter Rate D", 		"loiter_rate_d"));
			m.addDivider(new QuickMenuDivider());

			// Nav
			m.addItem(new QuickMenuItem("Nav Rate P", 			"nav_rate_p"));
			m.addItem(new QuickMenuItem("Nav Rate I", 			"nav_rate_i"));
			m.addItem(new QuickMenuItem("Nav Rate D", 			"nav_rate_d"));
			m.addDivider(new QuickMenuDivider());

			//m.addItem(new QuickMenuItem("Desired Speed", 		"desired_speed"));
			m.addItem(new QuickMenuItem("Nav Roll",		 		"nav_lon"));


			m.addItem(new QuickMenuItem("Accel X",				"accel_x"));
			m.addItem(new QuickMenuItem("Accel Z",				"accel_z"));

			m.addItem(new QuickMenuItem("throttle Cruise",		"throttle_cruise"));
			m.addItem(new QuickMenuItem("Angle Boost",			"angle_boost"));
			m.addItem(new QuickMenuItem("Throttle Output",		"throttle_out"));
			m.addItem(new QuickMenuItem("Motor 1",				"motor_1"));
			m.addItem(new QuickMenuItem("Motor 2",				"motor_2"));

			m.addItem(new QuickMenuItem("Wind Speed",			"wind_speed"));
		}

	    public function addedToStage(even:Event):void
		{
            stage.scaleMode		= StageScaleMode.NO_SCALE;
          	stage.align			= StageAlign.TOP_LEFT;

			g = Parameters.getInstance();
			g.visible = false;

			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);

			sim_controller.setLabel("START SIM");
			sim_controller.setEventName("RUN_SIM");
			stage.addEventListener("RUN_SIM",simHandler);

			graph_button.setLabel("Clear Graph");
			graph_button.setEventName("CLEAR_GRAPH");
			stage.addEventListener("CLEAR_GRAPH",graphHandler);

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
			rc_throttle.sticky = true;

			init_sim();

			// PLOTTING
			//addChildAt(plotView, 0);
			plotView.dataScaleY		= 0.25
			plotView.dataScaleX		= 3.0

			plotMenu.setSelectedItemByName("WP Distance");
			plotMenu.setSelectedItemByName("Roll Sensor");

			this.addEventListener(Event.ENTER_FRAME, idle);
		}

		public function idle(e:Event):void
		{
			if(medium_loop_counter++ >= 5){
				medium_loop_counter	= 0;
				update_altitude();

				next_WP.lng				= g.target_distance_BI.getNumber();
				next_WP.alt				= g.target_altitude_BI.getNumber();

				copter.position.z		= copter.loc.alt = g.start_height_BI.getNumber(); // add in some delay
				if(g.start_position_BI.getNumber() != 0)
					copter.position.x = g.start_position_BI.getNumber();
				sky.draw()
				sky.failsafe_MC.visible = false;
			}

			// fake a GPS read
			read_gps();

			if (g_gps.new_data == true){
				g_gps.new_data = false;
				update_GPS();
				iteration = 0;
			}
		}

		public function runSim(e:Event):void
		{
			update_sim_radio();

			// run twice to get 100hz updates
			loop();
			elapsed += 10; // 50 * 20  = 1000 ms
			loop();
			elapsed += 10; // 50 * 20  = 1000 ms

			// fake a GPS read
			read_gps();

			sky.draw();
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

			// custom code/exceptions for flight modes
			// ---------------------------------------
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
					if(fastPlot == false){
						plot(plotType_A, plot_A , 1);
						plot(plotType_B, plot_B , 2);
					}

					medium_loopCounter++;
					elapsed_time_tf.text = formatTime(elapsed) + " " + iteration.toString();

					//debug_TF.text = x_actual_speed +"\n"+ x_target_speed.toFixed(2) + "\n" + x_rate_error.toFixed(2)  + "\n" +ahrs.roll_sensor.toFixed(2)+"\n"+ p_loiter_rate.toFixed(2)  + "\n" + i_loiter_rate.toFixed(2) + "\n" + d_loiter_rate.toFixed(2) ;
					debug_TF.text = Math.floor(current_loc.alt) +"\n" + Math.floor(current_loc.lng) +"\n"+ Math.floor(x_actual_speed) +"\n" + Math.floor(climb_rate);

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

						Log_Write_Nav_Tuning();
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
						Log_Write_Attitude();

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


		public function fifty_hz_loop():void
		{
			// read altitude sensors or estimate altitude
			// ------------------------------------------
			update_altitude_est();

			// moved to slower loop
			// --------------------
			//trace("asdasd ",throttle_mode);
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

					if(superslow_loopCounter > 1200){
						// save compass offsets
						superslow_loopCounter = 0;
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
					//read_control_switch();

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
						//pitch_axis 	+= g.rc_2.control_in * g.axis_lock_p;

						roll_axis = wrap_360(roll_axis);
						//pitch_axis = wrap_360(pitch_axis);

						control_roll = roll_axis; // for debugging

						// in this mode, nav_roll and nav_pitch = the iterm
						g.rc_1.servo_out = get_stabilize_roll(roll_axis);
						//g.rc_2.servo_out = get_stabilize_pitch(pitch_axis);

						if (g.rc_3.control_in == 0){
							roll_axis = 0;
							//pitch_axis = 0;
						}

					}else{
						control_roll = g.rc_1.control_in; // for debugging
						// ACRO does not get SIMPLE mode ability
						g.rc_1.servo_out = get_acro_roll(g.rc_1.control_in);
						//g.rc_2.servo_out = get_acro_pitch(g.rc_2.control_in);
					}
					break;

				case ROLL_PITCH_STABLE:
					// apply SIMPLE mode transform
					if(do_simple && new_radio_frame){
						update_simple_mode();
					}

					//g.rc_1.control_in = constrain(g.rc_1.control_in, -1300, 1300);
					// in this mode, nav_roll and nav_pitch = the iterm
					g.rc_1.servo_out = get_stabilize_roll(g.rc_1.control_in);

					//g.rc_2.servo_out = get_stabilize_pitch(g.rc_2.control_in);

					control_roll = g.rc_1.control_in; // debugging
					break;

				case ROLL_PITCH_AUTO:
					// apply SIMPLE mode transform
					if(do_simple && new_radio_frame){
						update_simple_mode();
					}
					// mix in user control with Nav control
					nav_roll			+= constrain(wrap_180(auto_roll  - nav_roll),  -g.auto_slew_rate, g.auto_slew_rate); // 40 deg a second
					//nav_pitch			+= constrain(wrap_180(auto_pitch - nav_pitch), -g.auto_slew_rate.get(), g.auto_slew_rate.get()); // 40 deg a second

					control_roll 		= g.rc_1.control_mix(nav_roll);
					//control_pitch 		= g.rc_2.control_mix(nav_pitch);
					g.rc_1.servo_out 	= get_stabilize_roll(control_roll);
					//g.rc_2.servo_out 	= get_stabilize_pitch(control_pitch);
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

				//pitch_scale_d	= g.stabilize_d_schedule * Math.abs(g.rc_2.control_in);
				//pitch_scale_d 	= (1 - (pitch_scale_d / 4500.0));
				//pitch_scale_d 	= constrain(pitch_scale_d, 0, 1) * g.stabilize_d;
			}
		}

		// new radio frame is used to make sure we only call this at 50hz
		public function update_simple_mode():void
		{
			var simple_sin_y:Number = 0;
			var simple_cos_x:Number = 0;

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

			switch(throttle_mode){
				case THROTTLE_MANUAL:
					if (g.rc_3.control_in > 0){
						if (control_mode == ACRO){
							g.rc_3.servo_out 	= g.rc_3.control_in;
						}else{
							angle_boost = get_angle_boost(g.throttle_cruise);
							copter.angle_boost = angle_boost;
							//angle_boost 		= get_angle_boost(g.rc_3.control_in);
							g.rc_3.servo_out 	= g.rc_3.control_in + angle_boost;
						}

						// ensure throttle_avg has been initialised
						if( throttle_avg == 0 ) {
							throttle_avg = g.throttle_cruise;
						}
						// calc average throttle
						if ((g.rc_3.control_in > MINIMUM_THROTTLE) && Math.abs(climb_rate) < 60){
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
						takeoff_complete = false;
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

							// get the AP throttle
							nav_throttle = get_nav_throttle(altitude_error);
						}

						// hack to remove the influence of the ground effect
						if(g.sonar_enabled && current_loc.alt < 100 && landing_boost != 0) {
							nav_throttle = Math.min(nav_throttle, 0);
						}

						throttle_out = g.throttle_cruise + nav_throttle + angle_boost - landing_boost;
					}

					// light filter of output
					//g.rc_3.servo_out = (g.rc_3.servo_out * (THROTTLE_FILTER_SIZE - 1) + throttle_out) / THROTTLE_FILTER_SIZE;

					//var desired_accel:Number = copter.gravity;
					/*
					var thr_tmp:Number = (g.rc_3.radio_in - 1500) / 500;
					var desired_accel:Number = copter.gravity + 400 * thr_tmp;
					desired_accel = 981;

					nav_thrust_z = (desired_accel * g.throttle_cruise) / (copter.gravity * cos_roll_x);
					*/
					//trace(" ", thr_tmp, desired_accel, nav_thrust_z, ahrs.roll_sensor);
					//trace("nav_thrust_z", nav_thrust_z, throttle_out)

					// no filter
					g.rc_3.servo_out = throttle_out;
					break;
			}
		}

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
					//update_auto_yaw();

					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

				case GUIDED:
					wp_control = WP_MODE;
					// check if we are close to point > loiter
					wp_verify_byte = 0;
					verify_nav_wp();

					if (wp_control == WP_MODE) {
						//update_auto_yaw();
					} else {
						set_mode(LOITER);
					}
					update_nav_wp();
					break;

				case RTL:
					// We have reached Home
					if((wp_distance <= g.waypoint_radius) || check_missed_wp()){
						trace("reached home")
						// if loiter_timer value > 0, we are set to trigger auto_land or approach after 20 seconds
						set_mode(LOITER);

						// XXX be sure to loiter exactly above home!
						next_WP = home.clone();

						if(g.rtl_land_enabled || failsafe)
							loiter_timer = millis();
						else
							loiter_timer = 0;
						break;
					}

					wp_control = WP_MODE;
					slow_wp = true;


					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

					// switch passthrough to LOITER
				case LOITER:
				case POSITION:
					// This feature allows us to reposition the quad when the user lets
					// go of the sticks

					if((Math.abs(g.rc_2.control_in) + Math.abs(g.rc_1.control_in)) > 500){
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
						if(g.rtl_approach_alt >= 1 && (millis() - loiter_timer) > (RTL_APPROACH_DELAY * 1000)){
							// just to make sure we clear the timer
							loiter_timer = 0;
							set_mode(APPROACH);

						// Kick us out of loiter and begin landing if the loiter_timer is set
						} else if((millis() - loiter_timer) > g.auto_land_timeout){
							trace("auto_land_timeout, let's Land");
							// just to make sure we clear the timer
							loiter_timer = 0;
							set_mode(LAND);
							// XXX be sure to loiter above home!
							//set_next_WP(home);
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

				case APPROACH:
					// calculates the desired Roll and Pitch
					update_nav_wp();
					break;

				case CIRCLE:
					yaw_tracking	= MAV_ROI_WPNEXT;
					wp_control 		= CIRCLE_MODE;

					// calculates desired Yaw
					//update_auto_yaw();
					update_nav_wp();
					break;

				case STABILIZE:
					wp_control = NO_NAV_MODE;
					update_nav_wp();
					break;

			}
		}

		public function update_GPS()
		{
			if(g_gps.new_data == true){
				//iteration++;
				g_gps.new_data = false;
				nav_ok = true;

				current_loc.lng = g_gps.longitude// + x_actual_speed/2;
				//current_loc.lat = g_gps.latitude;
				calc_XY_velocity();
				//Log_Write_GPS();
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

		public function get_acro_roll(target_rate:int):int
		{
			target_rate = target_rate * g.acro_p;
			//target_rate = constrain(target_rate, -10000, 10000);
			return get_rate_roll(target_rate);
		}

		public function get_rate_roll(target_rate:Number):Number
		{
			var current_rate	:Number = 0;
			//roll_rate_error
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
			//if(g.test)
			//	output = constrain(output, -4500, 4500);
			//else
				output = constrain(output, -2500, 2500);

			roll_output = output

			// output control
			return output;
		}

		// call at 10hz
		public function get_nav_throttle(z_error:Number):Number
		{
			var output:Number = 0;

			// convert to desired Rate:
			z_target_speed 		= g.pi_alt_hold.get_p(z_error);			// calculate desired speed from lon error
			z_target_speed		= constrain(z_target_speed, -250, 250);

			// limit error to prevent I term wind up
			z_error				= constrain(z_error, -400, 400);

			// compensates throttle setpoint error for hovering
			i_hold				= g.pi_alt_hold.get_i(z_error , m_dt);			// calculate desired speed from lon error

			// calculate rate error
			z_rate_error		= z_target_speed - climb_rate;		// calc the speed error

			p_alt_rate			= g.pid_throttle.get_p(z_rate_error);
			i_alt_rate			= g.pid_throttle.get_i(z_rate_error + z_error, m_dt);
			d_alt_rate			= g.pid_throttle.get_d(z_error, m_dt);
			d_alt_rate			= constrain(d_alt_rate, -2000, 2000);


			// acceleration error
			var z_desired_accel :Number = 0;
			var z_accel_error	:Number = 0;
			z_accel_error 		= 	z_desired_accel - ahrs.accel.z;


			//var accel_d:Number 		= ahrs.accel.z;

			if (Math.abs(climb_rate) < 20)
				d_alt_rate = 0;

			output					= p_alt_rate + i_alt_rate + d_alt_rate;
			d_alt_accel				= -ahrs.accel.z * g.alt_D;
			output					+= d_alt_accel;
			//trace(ahrs.accel.z);
			//trace("output"+ output + "z_accel_error", z_accel_error);

			// limit the rate
			output					= constrain(output, -80, 120);

			return output + i_hold;
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
			//lat_error  				= 0;

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
		}

		public function reset_rate_I():void
		{
			g.pid_rate_roll.reset_I();
			//g.pid_rate_pitch.reset_I();
			//g.pid_rate_yaw.reset_I();
		}

		public function reset_wind_I():void
		{
			// Wind Compensation
			// this i is not currently being used, but we reset it anyway
			// because someone may modify it and not realize it, causing a bug
			//g.pi_loiter_lat.reset_I();
			g.pi_loiter_lon.reset_I();
			g.pid_loiter_rate_lon.reset_I();

			//g.pid_loiter_rate_lat.reset_I();
			g.pid_loiter_rate_lon.reset_I();

			//g.pid_nav_lat.reset_I();
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
			//g.pi_stabilize_pitch.reset_I();
		}

		public function get_angle_boost(value:Number):Number
		{
			/*
			var temp:Number = cos_pitch_x * cos_roll_x;
			//temp = 1.0 - constrain(temp, .5, 1.0);
			temp = 1.0 - temp;
			return Math.floor(constrain(temp * value, 0, 240));
			*/
			var temp:Number = cos_pitch_x * cos_roll_x;
			if(temp < 0) temp = 1;
			temp = constrain(temp, .5, 1);
			trace(temp,ahrs.roll_sensor);

			return (g.throttle_cruise / temp) - g.throttle_cruise;


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

		public function read_alt_to_hold():Number
		{
			return current_loc.alt;
			/*
			if(g.RTL_altitude <= 0)
				return current_loc.alt;
			else
				return g.RTL_altitude;// + home.alt;
			*/
		}

		public function set_next_WP(wp:Location):void
		{
			// Load the next_WP slot
			// ---------------------
			next_WP = wp.clone();

			// used to control and limit the rate of climb
			// -------------------------------------------
			// We don't set next WP below 1m
			next_WP.alt = Math.max(next_WP.alt, 100);

			// Save new altitude so we can track it for climb_rate
			set_new_altitude(next_WP.alt);

			// this is handy for the groundstation
			// -----------------------------------
			wp_distance = get_distance(current_loc, next_WP);

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
			home.lng 	= g_gps.longitude;				// Lon * 10**7
			home.lat 	= g_gps.latitude;				// Lat * 10**7
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
					trace("do command nav WP")
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


		//public function handle_no_commands()
		/*{
			switch (control_mode){
				default:
					set_mode(RTL);
					break;
			}
			return;
			Serial.println("Handle No CMDs");
		}*/

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
					return false;
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
			temp.alt		= read_alt_to_hold();

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

			// command_nav_queue.alt is a relative altitude!!!
			if (command_nav_queue.options & MASK_OPTIONS_RELATIVE_ALT) {
				temp.alt = command_nav_queue.alt + home.alt;
				//Serial.printf("rel alt: %ld",temp.alt);
			} else {
				temp.alt = command_nav_queue.alt;
				//Serial.printf("abs alt: %ld",temp.alt);
			}

			// prevent flips
			reset_I_all();

			// Set our waypoint
			set_next_WP(temp);
		}

		public function do_nav_wp():void
		{
			wp_control = WP_MODE;

			// command_nav_queue.alt is a relative altitude!!!
			if (command_nav_queue.options & MASK_OPTIONS_RELATIVE_ALT) {
				command_nav_queue.alt	+= home.alt;
			}
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

			// Set a new target altitude very low, incase we are landing on a hill!
			set_new_altitude(-1000);
		}

		public function do_approach():void
		{
			// Set a contrained value to EEPROM
			g.rtl_approach_alt = constrain(g.rtl_approach_alt, 1.0, 10.0);

			// Get the target_alt in cm
			var target_alt:Number = g.rtl_approach_alt * 100;

			// Make sure we are not using this to land and that we are currently above the target approach alt
			if(g.rtl_approach_alt >= 1 && current_loc.alt > target_alt){
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

				// Set target alt based on user setting
				set_new_altitude(target_alt);
			} else {
				set_mode(LOITER);
			}
		}

		public function do_loiter_unlimited():void
		{
			wp_control = LOITER_MODE;

			//Serial.println("dloi ");
			if(command_nav_queue.lat == 0)
				set_next_WP(current_loc);
			else
				set_next_WP(command_nav_queue);
		}

		public function do_loiter_turns():void
		{
			wp_control = CIRCLE_MODE;

			// reset desired location


			if(command_nav_queue.lat == 0){
				// allow user to specify just the altitude
				if(command_nav_queue.alt > 0){
					current_loc.alt = command_nav_queue.alt;
				}
				set_next_WP(current_loc);
			}else{
				set_next_WP(command_nav_queue);
			}

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
				if(current_loc.alt < 40 || Math.abs(climb_rate) < 20) {
					landing_boost++;  // reduce the throttle at twice the normal rate
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
				if(Math.abs(climb_rate) < 20) {
					//trace("climb_rate",climb_rate);
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
			if((wp_distance <= g.waypoint_radius) || check_missed_wp()){

				// if we have a distance calc error, wp_distance may be less than 0
				if(wp_distance > 0){
					wp_verify_byte |= NAV_LOCATION;

					if(loiter_time == 0){
						loiter_time = millis();
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
				trace("Reached Command ", command_nav_index)
				wp_verify_byte = 0;
				return true;
			}else{
				return false;
			}
		}

		//public function verify_loiter_unlim()
		//{
		//	return false;
		//}

		public function verify_loiter_time():Boolean
		{
			if(wp_control == LOITER_MODE){
				if ((millis() - loiter_time) > loiter_time_max) {
					return true;
				}
			}
			if(wp_control == WP_MODE &&  wp_distance <= g.waypoint_radius){
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
			// loiter at the WP
			wp_control 	= WP_MODE;

			// Did we pass the WP?	// Distance checking
			if((wp_distance <= g.waypoint_radius) || check_missed_wp()){
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
			command_yaw_speed		= command_cond_queue.lat * 100; 	// ms * 100
			command_yaw_relative	= command_cond_queue.lng;			// 1 = Relative,	 0 = Absolute



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
					// we are out of commands
					g.command_index  = command_nav_index = 255;
					// if we are on the ground, enter stabilize, else Land
					if (land_complete == true){
						// we will disarm the motors after landing.
					} else {
						set_mode(LAND);
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
			//	Log_Write_Cmd(g.command_index, command_nav_queue);

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
		public function reset_control_switch():void
		{
			oldSwitchPosition = -1;
			//read_control_switch();
		}

		// read at 10 hz
		// set this to your trainer switch
		public function read_trim_switch():void
		{
			// this is the normal operation set by the mission planner
			if(g.ch7_option == CH7_SIMPLE_MODE){
				do_simple = (g.rc_7.radio_in > CH_7_PWM_TRIGGER);

			}else if (g.ch7_option == CH7_RTL){
				if (trim_flag == false && g.rc_7.radio_in > CH_7_PWM_TRIGGER){
					trim_flag = true;
					set_mode(RTL);
				}

				if (trim_flag == true && g.rc_7.control_in < 800){
					trim_flag = false;
					if (control_mode == RTL || control_mode == LOITER){
						reset_control_switch();
					}
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
							// this is our first WP, let's save WP 1 as a takeoff
							// increment index to WP index of 1 (home is stored at 0)
							CH7_wp_index = 1;

							// set our location ID to 16, MAV_CMD_NAV_WAYPOINT
							current_loc.id = MAV_CMD_NAV_TAKEOFF;

							// save command:
							// we use the current altitude to be the target for takeoff.
							// only altitude will matter to the AP mission script for takeoff.
							// If we are above the altitude, we will skip the command.
							trace("save loc");
							set_cmd_with_index(current_loc, CH7_wp_index);
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


		// ---------------------------------------------------------------
		// motors.pde
		// ---------------------------------------------------------------

		public function init_arm_motors():void
		{
			motors.armed = true;

			// Reset home position
			// -------------------
			if(home_is_set)
				init_home();

			// all I terms are invalid
			// -----------------------
			reset_I_all();
			update_arm_label();
		}

		public function init_disarm_motors():void
		{
			trace("Disarm Motors");
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
			//var pitch_out	:int = 0
			var out_min		:int = g.rc_3.radio_min;
			var out_max 	:int = g.rc_3.radio_max;
			//trace("out_max", out_max, "out_min", out_min);

			// Throttle is 0 to 1000 only
			g.rc_3.servo_out 	= constrain(g.rc_3.servo_out, 0, MAXIMUM_THROTTLE);

			if(g.rc_3.servo_out > 0)
				out_min = g.rc_3.radio_min + MINIMUM_THROTTLE;

			g.rc_1.calc_pwm();
			//g.rc_2.calc_pwm();
			g.rc_3.calc_pwm();

			roll_out 	 		= g.rc_1.pwm_out; // 157 pwm
			//pitch_out 	 	= g.rc_2.pwm_out;

			//trace(Math.floor(g.rc_3.control_in),Math.floor(g.rc_3.servo_out), Math.floor(g.rc_3.radio_out), roll_out)

			// right motor
			motor_out[MOT_1]	= g.rc_3.radio_out - roll_out;
			// left motor
			motor_out[MOT_2]	= g.rc_3.radio_out + roll_out;


			// XXX skipping YAW

			/* We need to clip motor output at out_max. When cipping a motors
			 * output we also need to compensate for the instability by
			 * lowering the opposite motor by the same proportion. This
			 * ensures that we retain control when one or more of the motors
			 * is at its maximum output
			 */

			for (var i:int = MOT_1; i <= MOT_2; i++){
				if(motor_out[i] > out_max){
					// note that i^1 is the opposite motor
					motor_out[i ^ 1] -= motor_out[i] - out_max;
					motor_out[i] = out_max;
				}
			}

			// XXX do simple implementation

			// limit output so motors don't stop
			motor_out[MOT_1]	= Math.max(motor_out[MOT_1], 	out_min);
			motor_out[MOT_2]	= Math.max(motor_out[MOT_2], 	out_min);

			motor_out[MOT_1]	= Math.min(motor_out[MOT_1], 	out_max);
			motor_out[MOT_2]	= Math.min(motor_out[MOT_2], 	out_max);

			// cut motors
			if(g.rc_3.servo_out == 0){
				motor_out[MOT_1]	= g.rc_3.radio_min;
				motor_out[MOT_2]	= g.rc_3.radio_min;
			}

			//trace("motors", Math.floor(motor_out[MOT_1]), Math.floor(motor_out[MOT_2]));

			apm_rc.outputCh(MOT_1, motor_out[MOT_1]);
			apm_rc.outputCh(MOT_2, motor_out[MOT_2]);
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

			//trace("target_bearing ",target_bearing);

			// nav_bearing will includes xtrac correction
			// ------------------------------------------
			nav_bearing = target_bearing;
		}

		public function update_nav_wp()
		{
			if(wp_control == LOITER_MODE){

				// calc error to target
				calc_location_error(next_WP);

				// use error as the desired rate towards the target
				calc_loiter(long_error);

				// rotate pitch and roll to the copter frame of reference
				calc_loiter_pitch_roll();

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
				//circle_WP.lat = next_WP.lat + (g.loiter_radius * 100 * Math.sin(1.57 - circle_angle));

				// calc the lat and long error to the target
				calc_location_error(next_WP);

				// use error as the desired rate towards the target
				// nav_lon, nav_lat is calculated
				calc_loiter(long_error);

				//CIRCLE: angle:29, dist:0, lat:400, lon:242

				// rotate pitch and roll to the copter frame of reference
				calc_loiter_pitch_roll();

				// debug
				//int angleTest = degrees(circle_angle);
				//int nroll = nav_roll;
				//int npitch = nav_pitch;
				//Serial.printf("CIRCLE: angle:%d, dist:%d, X:%d, Y:%d, P:%d, R:%d  \n", angleTest, (int)wp_distance , (int)long_error, (int)lat_error, npitch, nroll);

			}else if(wp_control == WP_MODE){
				// calc error to target
				calc_location_error(next_WP);

				desired_speed = calc_desired_speed(g.waypoint_speed_max, slow_wp);
				//trace("desired_speed" , desired_speed)
				// use error as the desired rate towards the target
				calc_nav_rate(desired_speed);

				// rotate pitch and roll to the copter frame of reference
				calc_loiter_pitch_roll();

			}else if(wp_control == NO_NAV_MODE){
				// clear out our nav so we can do things like land straight down
				// or change Loiter position

				// We bring copy over our Iterms for wind control, but we don't navigate
				nav_lon	= g.pid_loiter_rate_lon.get_integrator();

				nav_lon			= constrain(nav_lon, -2000, 2000);			// 20°

				// rotate pitch and roll to the copter frame of reference
				calc_loiter_pitch_roll();
			}
		}

		public function calc_loiter_pitch_roll():void
		{
			auto_roll	= nav_lon
		}

		public function calc_desired_speed(max_speed:Number, _slow:Boolean):Number
		{
			if(_slow){
				max_speed		= Math.min(max_speed, wp_distance / 2);
				max_speed		= Math.max(max_speed, 0);
			}else{
				max_speed		= Math.min(max_speed, wp_distance);
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

		public function get_altitude_error():Number
		{
			// Next_WP alt is our target alt
			// It changes based on climb rate
			// until it reaches the target_altitude
			return next_WP.alt - current_loc.alt;
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
				if(current_loc.alt >=  target_altitude){
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

		public function calc_location_error(next_loc:Location):void
		{
			long_error = next_loc.lng - current_loc.lng;
		}

		public function calc_loiter(x_error:Number):void
		{
			var output:Number;
			x_target_speed			= g.pi_loiter_lon.get_p(x_error);			// calculate desired speed from lon error
			//trace("x_error", x_error, "x_target_speed" ,x_target_speed, "x_actual_speed",x_actual_speed, "x_rate_error", x_rate_error)
			x_rate_error			= x_target_speed - x_actual_speed;			// calc the speed error

			p_loiter_rate			= g.pid_loiter_rate_lon.get_p(x_rate_error);
			i_loiter_rate			= g.pid_loiter_rate_lon.get_i(x_rate_error + x_error , dTnav);
			d_loiter_rate			= g.pid_loiter_rate_lon.get_d(x_error, dTnav);
			d_loiter_rate			= constrain(d_loiter_rate, -2000, 2000);

			if (Math.abs(x_actual_speed) < 50)
				d_loiter_rate = 0;

			output					= p_loiter_rate + i_loiter_rate + d_loiter_rate;
			//trace(output);
			nav_lon					= constrain(output, -3000, 3000);			// 30°
		}

		public function calc_nav_rate(max_speed:Number):void
		{
			var output:Number;
			// nav_bearing includes crosstrack
			var temp:Number = (9000 - nav_bearing) * RADX100;

			// East / West
			//x_rate_error	= max_speed - x_actual_speed; // 413
			x_target_speed	= (Math.cos(temp) * max_speed);
			x_rate_error 	= x_target_speed - x_actual_speed; // 413

			//x_rate_error	= constrain(x_rate_error, -1000, 1000);
			//nav_lon			= g.pid_nav_lon.get_pid(x_rate_error, dTnav);

			p_nav_rate			= g.pid_nav_lon.get_p(x_rate_error);
			i_nav_rate			= g.pid_nav_lon.get_i(x_rate_error, dTnav);
			d_nav_rate			= g.pid_nav_lon.get_d(x_rate_error, dTnav);
			d_nav_rate			= constrain(d_loiter_rate, -2000, 2000);

			if (Math.abs(x_actual_speed) < 50)
				d_nav_rate = 0;

			output					= p_nav_rate + i_nav_rate + d_nav_rate;

			nav_lon			= constrain(output, -3000, 3000);

			// copy over I term to Loiter_Rate
			g.pid_loiter_rate_lon.set_integrator(g.pid_nav_lon.get_integrator());

		}

		public function update_trig():void
		{
			cos_pitch_x = 1;
			cos_roll_x 	= Math.cos(radiansx100(ahrs.roll_sensor));
		}

		// call at 10hz
		public function update_altitude():void
		{
			// read barometer
			baro_alt 				= baro.read();

			// calc the vertical accel rate
			var temp:Number		= (baro_alt - old_baro_alt) * 10;
			baro_rate 			= (temp + baro_rate) >> 1;
			baro_rate			= constrain(baro_rate, -300, 300);
			old_baro_alt		= baro_alt;

			current_loc.alt 		= baro_alt;
			climb_rate	 			= (current_loc.alt - old_altitude) * 10;
			old_altitude 			= current_loc.alt;

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
					current_loc.alt = baro_alt + home.alt; // home alt = 0
					// dont blend, go straight baro
					climb_rate_actual 	= baro_rate;
				}

			}else{
				// NO Sonar case
				current_loc.alt 	= baro_alt + home.alt;
				climb_rate_actual 	= baro_rate;
			}

			// update the target altitude
			next_WP.alt = get_new_altitude();
			//trace("next_WP.alt", next_WP.alt);

			// calc error
			climb_rate_error = (climb_rate_actual - climb_rate) / 5;
		}

		public function update_altitude_est():void
		{
			if(alt_sensor_flag){
				update_altitude();
				alt_sensor_flag = false;
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
			if(g.rc_3.control_in <= (MINIMUM_THROTTLE + THROTTLE_ADJUST)){
				// we remove 0 to 100 PWM from hover
				manual_boost = (g.rc_3.control_in - MINIMUM_THROTTLE) - THROTTLE_ADJUST;
				manual_boost = Math.max(-THROTTLE_ADJUST, manual_boost);

			}else if  (g.rc_3.control_in >= (MAXIMUM_THROTTLE - THROTTLE_ADJUST)){
				// we add 0 to 100 PWM to hover
				manual_boost = g.rc_3.control_in - (MAXIMUM_THROTTLE - THROTTLE_ADJUST);
				manual_boost = Math.min(THROTTLE_ADJUST, manual_boost);

			}else {
				manual_boost = 0;
			}
		}


		public function calc_XY_velocity()
		{
			// initialise last_longitude
			if(last_longitude == 0){
				last_longitude = g_gps.longitude;
				g_gps.long_est = g_gps.longitude;
			}
			var tmp:Number = 1.0/dTnav;

			//if(g.gps_checkbox.getSelected() == false){
				x_actual_speed = lon_filter.apply((g_gps.longitude - last_longitude) * tmp);
				g_gps.long_est = g_gps.longitude;

				//g_gps.long_est = g_gps.longitude + x_actual_speed * 0;
					//if(limit < 100)
					//	trace(copter.loc.lng, g_gps.longitude, g_gps.long_est);

				last_longitude = g_gps.longitude;

			//}else{

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
			//}
		}

		// distance is returned in cm
		public function get_distance(loc1:Location, loc2:Location):Number
		{
			return	Math.abs(Math.floor((loc2.lng - loc1.lng) * 1.113195));
		}

		public function get_bearing(loc1:Location, loc2:Location):Number
		{
			var off_x:Number 	= loc2.lng - loc1.lng;
			var off_y:Number 	= (loc2.lat - loc1.lat) * scaleLongUp;
			var bearing:Number  = 9000 + Math.atan2(-off_y, off_x) * 5729.57795;
			if (bearing < 0) bearing += 36000;
			return Math.round(bearing);
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
			//g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);

			// Pitch
			//g.rc_2.servo_out = get_stabilize_pitch(0);

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


/********************************************************************************/
//
/********************************************************************************/


		public function check_missed_wp():Boolean
		{
			var temp:Number;
			temp = target_bearing - original_target_bearing;
			temp = wrap_180(temp);
			return (Math.abs(temp) > 10000);	// we passed the waypoint by 100 degrees
		}

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
			g.rc_3.set_range(MINIMUM_THROTTLE, MAXIMUM_THROTTLE);
			g.rc_4.set_angle(4500);

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
				g.rc_3.set_pwm(apm_rc.InputCh(CH_3));
				g.rc_4.set_pwm(apm_rc.InputCh(CH_4));
				g.rc_5.set_pwm(apm_rc.InputCh(CH_5));
				g.rc_6.set_pwm(apm_rc.InputCh(CH_6));
				g.rc_7.set_pwm(apm_rc.InputCh(CH_7));
				g.rc_8.set_pwm(apm_rc.InputCh(CH_8));

				// limit our input to 800 so we can still pitch and roll
				g.rc_3.control_in = Math.min(g.rc_3.control_in, MAXIMUM_THROTTLE);

			}
			throttle_failsafe(g.rc_3.radio_in);
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
				//reset_control_switch();


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


		// ----------------------------------------
		// Loging
		// ----------------------------------------
		private function Log_Write_Nav_Tuning():void
		{
			//			  wp_distance, (nav_bearing/100), long_error, lat_error, nav_lon, nav_lat, x_actual_speed, y_actual_speed, g.pid_nav_lon.get_integrator(), g.pid_nav_lat.get_integrator()
			//trace("NTUN", wp_distance, (nav_bearing/100), long_error, 0, nav_lon, 0, x_actual_speed, 0, g.pid_loiter_rate_lon.get_integrator());
		}

		private function Log_Write_Control_Tuning():void
		{
			//trace("CTUN", 0, copter.position.x, baro_alt, next_WP.alt, nav_throttle, angle_boost, manual_boost, climb_rate, copter.throttle, pid_throttle.get_integrator(), pid_rate_throttle.get_integrator());
		}
		private function Log_Write_Attitude():void
		{
			//trace("ATT", g.rc_1.control_in, ahrs.roll_sensor);
		}


		// ----------------------------------------
		// System.pde
		// ----------------------------------------
		public function set_mode(mode:int):void
		{
			trace("Set Mode", flight_mode_strings[mode]);

			control_mode 		= mode;

			// update pulldown in GUI
			modeMenu.setSelectedIndex(mode);

			// used to stop fly_aways
			motors.auto_armed = (g.rc_3.control_in > 0);

			// clearing value used in interactive alt hold
			manual_boost = 0;
			reset_throttle_flag = false;

			// clearing value used to force the copter down in landing mode
			landing_boost = 0;

			// do we want to come to a stop or pass a WP?
			slow_wp = false;

			// do not auto_land if we are leaving RTL
			loiter_timer = 0;

			// if we change modes, we must clear landed flag
			land_complete 	= false;

			switch(control_mode)
			{
				case ACRO:
					roll_pitch_mode = ROLL_PITCH_ACRO;
					throttle_mode 	= THROTTLE_MANUAL;
					break;

				case STABILIZE:
					roll_pitch_mode = ROLL_PITCH_STABLE;
					throttle_mode 	= THROTTLE_MANUAL;
					break;

				case ALT_HOLD:
					roll_pitch_mode = ROLL_PITCH_STABLE;
					throttle_mode 	= THROTTLE_HOLD;

					force_new_altitude(Math.max(current_loc.alt, 100));
					break;

				case AUTO:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;

					// loads the commands from where we left off
					init_commands();
					break;

				case CIRCLE:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_HOLD;
					set_next_WP(current_loc);
					circle_WP		= next_WP.clone();
					circle_angle 	= 0;
					break;

				case LOITER:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_HOLD;
					set_next_WP(current_loc);
					break;

				case POSITION:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_MANUAL;
					set_next_WP(current_loc);
					break;

				case GUIDED:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					next_WP 		= current_loc;
					//set_next_WP(guided_WP);
					break;

				case LAND:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					do_land();
					break;

				case APPROACH:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;
					do_approach();
					break;

				case RTL:
					roll_pitch_mode = ROLL_PITCH_AUTO;
					throttle_mode 	= THROTTLE_AUTO;

					do_RTL();
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
			stopSIM();
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
			trace("stop sim")
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
			trace("start sim")
			sim_controller.setLabel("STOP SIM");
			simIsRunnning = true;
			g.updateGains();
			init_sim();
			plotMenuHandler(null);
			plot_A = plotView.addPlot("plot_A", 	getNewColor());
			plot_B = plotView.addPlot("plot_B", 	getNewColor());
			this.removeEventListener(Event.ENTER_FRAME, idle);
			this.addEventListener(Event.ENTER_FRAME, runSim);


			// hide gains
			g.visible = false;
			gains_button.setLabel("Show Gains");
			sky.draw();
			//motors.armed = true;
			init_arm_motors();
			update_arm_label();

		}

		private function init_sim():void
		{
			iteration = 0;
			elapsed = 0;

			copter.setThrottleCruise(g.throttle_cruise);
			copter.velocity.x	= g.start_speed_BI.getNumber();
			copter.velocity.z	= g.start_climb_rate_BI.getNumber();
			copter.position.x 	= g.start_position_BI.getNumber();
			copter.position.z 	= g.start_height_BI.getNumber(); // add in some delay
			baro.enable_noise	= g.baro_noise_checkbox.getSelected();
			fastPlot			= g.fastPlot_checkbox.getSelected();

			copter.loc.lng 		= copter.position.x;
			copter.loc.alt 		= copter.position.z;
			current_loc.lng		= copter.loc.lng;
			current_loc.alt		= copter.loc.alt;
			copter.windGenerator.resetWind();


			reset_I_all();
			reset_nav_params();
			baro.init();
			ahrs.init();
			g_gps.init();
			copter.roll_target 	= nav_lon = 0;
			ahrs.roll_sensor	= g.start_angle_BI.getNumber();
			copter.rotation 	= ahrs.roll_sensor;

			// Copter state
			failsafe 			= false;
			takeoff_complete	= false;
			failsafeCounter		= 0;
			radio_failure 		= false;

			ahrs.roll_speed.x	= g.start_rotation_BI.getNumber();

			// hack
			init_home();

			// setup our next WP
			var nwp = new Location();
			nwp.lng = g.target_distance_BI.getNumber();
			nwp.alt = g.target_altitude_BI.getNumber();
			set_mode(modeMenu.getSelectedIndex());
			set_next_WP(nwp);

			// hack to make the SIM go right into Land
			if(control_mode == LAND)
				do_land();


			if(g.wind_checkbox.getSelected()){
				copter.windGenerator.setSpeed(g.wind_low_BI.getNumber(), g.wind_high_BI.getNumber());
				copter.windGenerator.setPeriod(g.wind_period_BI.getNumber()*1000);
			}else{
				copter.windGenerator.setSpeed(0, 0);
			}

			lon_filter 				= new AverageFilter(g.speed_filter_size);

			// radio
			init_rc_in();
			init_rc_out();
			default_dead_zones();
			// sets throttle to be at hovering setpoint
			rc_throttle.knob.x = 6;

			// setup a fake AP misison
			var loc:Location = new Location();
			loc.id = 16;

			loc.lng = -1000;
			loc.alt = 500;
			set_cmd_with_index(loc, 1);

			loc.lng = 0;
			loc.alt = 500;
			set_cmd_with_index(loc, 2);

			loc.lng = 1000;
			loc.alt = 500;
			set_cmd_with_index(loc, 3);

			loc.lng = 0;
			loc.alt = 500;
			set_cmd_with_index(loc, 4);

			loc.id = 21;
			loc.alt = 0;
			set_cmd_with_index(loc, 5);
		}


		public function update_sim_radio():void
		{
			//
			//read out rc_throttle and rc_roll

			if(radio_failure){
				ch_3_pwm = 1500;
			}else{
				ch_3_pwm = rc_throttle.pwm;
				ch_1_pwm = rc_roll.pwm;
			}

			apm_rc.set_PWM_channel(ch_1_pwm,	 	CH_1);
			apm_rc.set_PWM_channel(ch_2_pwm, 		CH_2);
			apm_rc.set_PWM_channel(ch_3_pwm,	 	CH_3);
			apm_rc.set_PWM_channel(ch_4_pwm, 		CH_4);
			apm_rc.set_PWM_channel(ch_5_pwm, 		CH_5);
			apm_rc.set_PWM_channel(ch_6_pwm, 		CH_6);
			apm_rc.set_PWM_channel(ch_7_pwm, 		CH_7);
			//apm_rc.set_PWM_channel(ch_8_pwm, 		CH_8);
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
					case 189: // 11 "-"
						set_mode(APPROACH);
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
						plotView.setScale((plotView.dataScaleX-1), plotView.dataScaleY)
						break;
					case 39: // Right
						plotView.setScale((plotView.dataScaleX+1), plotView.dataScaleY)
						break;

				}
			}

			switch(k.keyCode){

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

				case 83: // h for hover
					simHandler(null);
					break;

				case 72: // h for hover
					rc_throttle.knob.x = 6;
					break;

				case 76: // l for loop
					init_flip();
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
			//trace("item.getLabel()", item.getLabel());
			set_mode(modeMenu.getSelectedIndex());
		}

		private function armHandler(e:Event):void
		{
			motors.armed = !motors.armed;
			update_arm_label();
		}

		private function update_arm_label():void
		{
			trace("motors.armed", motors.armed);

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

				//case "desired_speed":
				//	val = desired_speed;
				//break;


				case "wp_distance":
					val = wp_distance;
				break;

				case "long_error":
					val = long_error;
				break;

				case "speed":
					val = x_actual_speed;
				break;

				case "x_target_speed":
					val = x_target_speed;
				break;

				case "x_rate_error":
					val = x_rate_error;
				break;

				case "nav_lon":
					val = nav_lon;
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


				case "nav_rate_p":
					val = p_nav_rate;
				break;

				case "nav_rate_i":
					val = i_nav_rate;
				break;

				case "nav_rate_d":
					val = d_nav_rate;
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
				break;

				case "z_target_speed":
					val = z_target_speed;
				break;

				case "alt_hold_i":
					val = i_hold;
				break;

				case "alt_rate_p":
					val = p_alt_rate;
				break;

				case "alt_rate_i":
					val = i_alt_rate;
				break;

				case "alt_rate_d":
					val = d_alt_rate;
				break;

				case "d_alt_accel":
					val = d_alt_accel;
					_scale = 100;
				break;

				case "accel_x":
					val = ahrs.accel.x
					_scale = 100;
				break;

				case "accel_z":
					val = ahrs.accel.z;
					_scale = 100;
				break;


				case "angle_boost":
					val = angle_boost;
				break;


				case "throttle_cruise":
					val = g.throttle_cruise;
				break;

				case "throttle_out":
					val = g.rc_3.servo_out;
				break;

				case "motor_1":
					val = motor_out[MOT_1] - 1000;
				break;

				case "motor_2":
					val = motor_out[MOT_2] - 1000;
				break;

				case "wind_speed":
					val = copter.wind.x;
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
			g.rc_3.set_range(MINIMUM_THROTTLE, MAXIMUM_THROTTLE);
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
			trace("cmd#: " + index + " id:" + cmd.id + " op:" + cmd.options + " p1:" + cmd.p1 + " p2:" + cmd.alt + " p3:" + cmd.lat + " p4:" + cmd.lng);
		}

		// call at 50hz
		public function read_gps():void
		{
			if((gps_counter++ % 13) == 0){
				g_gps.read()
			}

			// overflow the GPS counter
			if(gps_counter >= 50){
				gps_counter = 0;
			}
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
	}
}

