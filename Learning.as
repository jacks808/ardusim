/*
	RC_Channel.cpp - Radio library for Arduino
	Code by Jason Short. DIYDrones.com

	This library is free software; you can redistribute it and / or
		modify it under the terms of the GNU Lesser General Public
		License as published by the Free Software Foundation; either
		version 2.1 of the License, or (at your option) any later version.

*/

package com {
	import flash.display.MovieClip;
    import flash.events.*;
    import com.Main;
    import com.Location;

	public class Learning extends MovieClip
	{
		// GUI
		public var waypoints			:Array;
		public var controller			:Main;
		public var lat_offset			:int;
		public var lng_offset			:int;

		public function Learning()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			visible = false;
		}

	    public function addedToStage(even:Event):void
		{

		}


	    public function update():void
		{

		}


	}
}
