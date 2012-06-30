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

	public class Ground extends MovieClip
	{
		//public var lines			:int = 4;
		public var copter_XY		:Point;
		public var nextwp_XY		:Point;
		public var prevwp_XY		:Point;

		public var frame			:Rectangle;
		public var copter			:Copter;
		public var ghost			:MovieClip;
		public var controller		:Main;
		public var current_loc		:Location;

		public var line				:MovieClip;

		public function Ground(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			frame 			= new Rectangle(0,0,100,100);
			copter_XY 		= new Point(0,0);
			nextwp_XY 		= new Point(0,0);
			prevwp_XY 		= new Point(0,0);
		}

		public function draw():void
		{
			//             c           	|     	n
			//            -40		   	0		20
			//							+40     + 60
			//             0  - -40
			//             20 - -40


			nav_yaw_MC.rotation = controller.nav_yaw/100;

			copter_XY.x 	= copter.loc.lng * 1.123;
			copter_XY.y 	= -copter.loc.lat;

			gps.x = (controller.current_loc.lng - copter.loc.lng) * 1.123;
			gps.y = (-controller.current_loc.lat) - copter_XY.y;

			prevwp_XY.x 	= controller.prev_WP.lng * 1.123 - copter_XY.x;
			prevwp_XY.y 	= (-controller.prev_WP.lat) - copter_XY.y;

			nextwp_XY.x 	= controller.next_WP.lng * 1.123 - copter_XY.x;
			nextwp_XY.y 	= (-controller.next_WP.lat) - copter_XY.y;


			grass.x = -copter_XY.x % 200 + 50;
			grass.y = -copter_XY.y % 200 - 50;

			target_.x = nextwp_XY.x;
			target_.y = nextwp_XY.y;


			line.graphics.clear();
			line.graphics.lineStyle(2, 0x000000);
			line.graphics.moveTo(prevwp_XY.x, prevwp_XY.y);
			line.graphics.lineTo(target_.x, target_.y);


			copter_mc.rotation 	= copter.ahrs.yaw_sensor/100;
			copter_mc.copter_xy.scaleX 	= controller.cos_roll_x;
			copter_mc.copter_xy.scaleY 	= controller.cos_pitch_x;


			copter_shadow.x = copter_mc.x + copter.loc.alt / 10;
			copter_shadow.y = copter_mc.y + copter.loc.alt / 10;

			copter_shadow.rotation 	= copter_mc.rotation;
			copter_shadow.copter_xy.scaleX 	= copter_mc.copter_xy.scaleX;
			copter_shadow.copter_xy.scaleY 	= copter_mc.copter_xy.scaleY;
			copter_shadow.scaleX = copter_shadow.scaleY = 1 - (copter.loc.alt / 4000);
		}


		public function addedToStage(event:Event):void
		{
			this.frame.width 	= Math.round(_preview.width);
			this.frame.height 	= Math.round(_preview.height);
			_preview.visible = false;
			scaleX = 1;
			scaleY = 1;
			//draw();
			line = new MovieClip()
			addChildAt(line, 3);
		}

		public function degrees(r:Number):Number
		{
			return r * 57.2957795;
		}

		public function radians(n:Number):Number
		{
			return 0.0174532925 * n;
		}

		public function radiansx100(n:Number):Number
		{
			return 0.000174532925 * n;
		}

	}
}
