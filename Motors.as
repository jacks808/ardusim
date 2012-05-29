package com {

	public class Motors {

		public var a_armed		:Boolean = false;

		public function Motors() {
		}

		public function set auto_armed(a:Boolean):void
		{
			a_armed = a;
		}

		public function get auto_armed():Boolean
		{
			return a_armed;
		}

		public function armed():Boolean
		{
			return true;
		}

	}
}

