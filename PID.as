package com {

	public class PID {

		public var _kp				:Number = 0;
		public var _ki				:Number = 0;
		public var _kd				:Number = 0;
		public var _imax			:Number = 0;
		public var _integrator		:Number = 0;
		public var _last_input		:Number = 0;
		public var _last_derivative	:Number = 0;
		public var _output			:Number = 0;
		public var _derivative		:Number = 0;

		public var _filter			:Number = 7.9577e-3; 		// Set to  "1 / ( 2 * PI * f_cut )";
		//public var _filter = 15.9155e-3; 		// Set to  "1 / ( 2 * PI * f_cut )";

		private var dfilter_h		:Number = .9;
		private var dfilter_l		:Number = .1;

		public function PID(kp:Number, ki:Number, kd:Number, imax:Number) {
			_kp = kp;
			_ki = ki;
			_kd = kd;
			_imax = imax;
		}

		public function get_integrator():Number
		{
			return _integrator;
		}
		public function set_integrator(i:Number):void
		{
			_integrator = i;
		}

		public function get_p(error:Number):Number
		{
			return error * _kp;
		}

		public function get_i(error:Number, dt:Number):Number
		{
			if((_ki != 0) && (dt != 0)){
				_integrator += (error * _ki) * dt;
				if (_integrator < -_imax) {
					_integrator = -_imax;
				} else if (_integrator > _imax) {
					_integrator = _imax;
				}
				return _integrator;
			}
			return 0;
		}


		public function set_d_filter(input:Number):void
		{
			input = constrain(input, 0, 1);
			dfilter_h = input;
			dfilter_l = 1 - dfilter_h;
		}

		public function get_d(input:Number, dt:Number):Number
		{
			if ((_kd != 0) && (dt != 0)) {
				_derivative = (input - _last_input) / dt;

				// discrete low pass filter, cuts out the
				// high frequency noise that can drive the controller crazy
				_derivative = _last_derivative + (dt / ( _filter + dt)) * (_derivative - _last_derivative);

				//_derivative = _derivative * dfilter_l + _last_derivative * dfilter_h;

				// update state
				_last_input 		= input;
				_last_derivative    = _derivative;

				// add in derivative component
				return _kd * _derivative;
			}
			return 0;
		}

		public function get_pid(error:Number, dt:Number):Number
		{
			return get_p(error) + get_i(error, dt) + get_d(error, dt);
		}

		public function get_pi(error:Number, dt:Number):Number
		{
			return get_p(error) + get_i(error, dt);
		}


		public function reset_I():void
		{
			_integrator = 0;
			_last_input = 0;
			_last_derivative = 0;
		}


		public function constrain(val:Number, min:Number, max:Number){
			val = Math.max(val, min);
			val = Math.min(val, max);
			return val;
		}

	}
}

