<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc Session操作类
 *
 */
final class MooSession implements MooSessionInterface {
	private $sessionStart = false;

	/**
	 * 添加一个session的值
	 *
	 * @param string $key
	 * @param mix $value
	 */
	static public function set($key, $value) {
		self::start();
		$_SESSION[$key] = $value;
	}

	/**
	 * 设置P3P
	 *
	 */
	public static function setP3P() {
		header('P3P: CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
	}
	
	/**
	 * 获取一个session的值
	 *
	 * @param string $key
	 * @return mix
	 */
	static public function get($key) {
		self::start();
		return $_SESSION[$key];
	}

	/**
	 * 清除session的值
	 *
	 * @param string $key
	 * @return mix
	 */
	static public function remove($key) {
		self::start();
		$_SESSION[$key] = '';
	}

	/**
	 * session_start
	 *
	 */
	static public function start() {
		$Session = self::_getInstance();
		if (!$Session->sessionStart) {
			session_start();
			$Session->sessionStart = true;
		}
	}
	
	/**
	 * session_destroy
	 * 
	 */
	static public function clear() {
		self::start();
		session_destroy();
	}

	/**
	 * 单键
	 *
	 */
	static private function _getInstance() {
		if (is_object($this) && $this instanceof MooSession) {
			return $this;
		}
		static $Session = null;
		if (!$Session) {
			$Session = new MooSession();
		}
		return $Session;
	}
}
