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
			copter.x 		= copter_XY.x % frame.width;
			if (copter.x < 0)
				copter.x	+= frame.width;

			copter_XY.y 	= frame.height - copter.loc.alt;
			copter.y 		= copter_XY.y % frame.height;
			if (copter.y < 0)
				copter.y	+= frame.height;

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

			copter.rotation = copter.ahrs.roll_sensor/100;
			copter_lag.rotation = copter.rotation;

			//loc_lng_TF.text = Math.floor(copter.loc.lng) +"cm";
			//loc_alt_TF.text = Math.floor(copter.loc.alt) +"cm";
			//speed_TF.text 	= Math.floor(copter.speed) +"cm/s";
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
			this.frame.width 	= Math.round(this.width);
			this.frame.height 	= Math.round(this.height);
			scaleX = 1;
			scaleY = 1;
			//draw();
		}
	}
}
