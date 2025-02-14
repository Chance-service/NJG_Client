<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc Cookie操作类
 *
 */
final class MooCookie implements MooCookieInterface {
	private $domain = '';
	private $path = '/';
	
	/**
	 * 设置cookie作用域
	 *
	 * @param string $domain
	 */
	public static function setDomain($domain) {
		$cookie = self::getInstance();
		$cookie->domain = $domain;
	}
	
	/**
	 * 设置P3P
	 *
	 */
	public static function setP3P() {
		header('P3P: CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
	}
	
	/**
	 * 设置cookie作用路径
	 *
	 * @param string $path
	 */
	public static function setPath($path) {
		$cookie = self::getInstance();
		$cookie->path = $path;
	}
	
	/**
	 * 设置COOKIE
	 *
	 * @param string $key
	 * @param mix $value
	 * @param int $expire
	 * @param boolean $secure
	 */
	public static function set($key, $value, $expire = 0, $secure = false) {
		$cookie = self::getInstance();
		setcookie($key, $value, $expire, $cookie->path, $cookie->domain, $secure);
		$_COOKIE[$key] = $value;
	}
	
	/**
	 * 获取COOKIE
	 *
	 * @param string $name
	 * @return mix
	 */
	public static function get($name) {
		return $_COOKIE[$name];
	}
	
	/**
	 * 删除COOKIE
	 *
	 * @param string $name
	 */
	public static function remove($name) {
		if (is_array($name)) {
			foreach ($name as $n) {
				self::remove($n);
			}
		} else {
			self::set($name, '', time() - 999999);
			unset($_COOKIE[$name]);
		}
	}
	
	/**
	 * 单键
	 *
	 * @return object
	 */
	private function getInstance() {
		if (is_object($this) && $this instanceof MooCookie) {
			return $this;
		}
		static $cookie = null;
		if (!$cookie) {
			$cookie = new MooCookie();
		}
		return $cookie;
	}
}