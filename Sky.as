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
	import flash.utils.*;
	import flash.ui.Keyboard;
    import flash.geom.Rectangle;

	import com.Copter;
	import com.Location;
	import com.Main;

	public class Sky extends MovieClip
	{
		//public var lines			:int = 4;
		public var copter_XY		:Point;
		public var ghost_XY			:Point;
		public var frame			:Rectangle;
		public var copter			:Copter;
		public var copter_mc		:MovieClip;
		public var copter_lag		:MovieClip;
		public var ghost			:MovieClip;
		public var controller		:Main;
		public var current_loc		:Location;
		public var x_page			:int;
		public var y_page			:int;
		public var x_page_g			:int;
		public var y_page_g			:int;


		public function Sky(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			frame 			= new Rectangle(0,0,100,100);
			copter_XY 		= new Point(0,0);
			ghost_XY 		= new Point(0,0);
		}

		public function draw():void
		{

			copter_XY.x 	= frame.width/2 + copter.loc.lng * 1.123;
			copter_mc.x 	= copter_XY.x % frame.width;
			if (copter_mc.x < 0)
				copter_mc.x	+= frame.width;

			copter_XY.y 	= frame.height - copter.loc.alt;
			copter_mc.y 	= copter_XY.y % frame.height;
			if (copter_mc.y < 0)
				copter_mc.y	+= frame.height;

			calc_copter_page();

			grass.visible = (y_page == 0);
			grass.scaleX  = ((x_page % 2) == 0) ? 1 : -1;

			//-----------------------------------------------------------------

			copter_lag.x 	= frame.width/2 + current_loc.lng * 1.123;
			copter_lag.x 	= copter_lag.x % frame.width;
			if (copter_lag.x < 0)
				copter_lag.x	+= frame.width;

			copter_lag.y 	= frame.height - current_loc.alt;

			copter_lag.y 	= copter_lag.y % frame.height;
			if (copter_lag.y < 0)
				copter_lag.y	+= frame.height;

			//-----------------------------------------------------------------

			ghost_XY.x 		= frame.width/2 + controller.next_WP.lng * 1.123;
			ghost.x 		= ghost_XY.x % frame.width;
			if (ghost.x < 0)
				ghost.x	+= frame.width;

			ghost_XY.y 		= frame.height - Math.max(controller.next_WP.alt, 0);
			ghost.y 		= ghost_XY.y % frame.height;
			if (ghost.y < 0)
				ghost.y	+= frame.height;

			calc_ghost_page();

			ghost.visible = ((x_page == x_page_g) && (y_page == y_page_g));

			//-----------------------------------------------------------------

			//if(copter.angle3D.z >0)
			//	copter_mc.rotation = -degrees(Math.asin(copter.angle3D.y));
			//else
			//	copter_mc.rotation = degrees(Math.asin(copter.angle3D.y));

			//trace(copter.ahrs.roll_sensor/100);
			//copter_mc.rotation = copter.ahrs.roll_sensor/100;

			copter_mc.rotation = degrees(Math.atan2(copter.angle3D.z, copter.angle3D.y)) -90;
			//trace("copter.angle3D.y", copter.angle3D.y, copter_mc.rotation);
		}

		public function calc_copter_page():void
		{
			x_page		= copter_XY.x / frame.width;
			y_page		= (frame.height - copter_XY.y) / frame.height;

			if (copter_XY.x  < 0)
				x_page--;
		}

		public function calc_ghost_page():void
		{
			x_page_g		= ghost_XY.x / frame.width;
			y_page_g		= (frame.height - ghost_XY.y) / frame.height;

			if (ghost_XY.x  < 0)
				x_page_g--;
		}

		public function addedToStage(event:Event):void
		{
			_preview.visible 	= false;
			this.frame.width 	= Math.round(_preview.width);
			this.frame.height 	= Math.round(_preview.height);
			scaleX = 1;
			scaleY = 1;
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
