package com {
	public class Location
	{
		var id				:Number = 0;
		var options			:Number = 0;
		var p1				:Number = 0;
		var alt				:Number = 0;
		var lat				:Number = 0;
		var lng				:Number = 0;
		var ground_course	:Number = 0;
		var ground_speed	:Number = 0;

		public function Location(){
		}

		public function clone(){
			var tmp = new Location();
			tmp.id 		= this.id;
			tmp.options = this.options;
			tmp.p1 		= this.p1;
			tmp.alt 	= this.alt;
			tmp.lat 	= this.lat;
			tmp.lng 	= this.lng;
			return tmp;
		}

	}
}



