<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc Cache数据记录类
 * 
 * expample:
 * 实力化这个对象即可。本类所有方法无须手工调用。
 * 
 */
final class MooRedisCacheDebug extends MooRedisCache {
	
	
	// TT服务器和端口配置
	private $config;

	// memcache server 数量
	private $serverNumber = 1;

	/**
	 * 设置TT的服务器和缓存类型
	 * $config = array();
	 * $config[0] = array('host' => 'server_memcache_01.memcache.com', 'port' => 11201);
	 * $config[1] = array('host' => 'server_memcache_02.memcache.com', 'port' => 11202);
	 * @param mixed	$config
	 * @return void
	 */
	public static function config($config = array()){
		global $_MooPHP;

		$cacheDebug = self::_getInstance();
		$cacheDebug->config = $config;
		$cacheDebug->serverNumber = count($config);

		parent::config($config);

	}


	/**
	 * 读取缓存 方法
	 *
	 * @param string 	$key 			缓存的key
	 * @param integer	$realExpired	指定实际缓存有效期
	 * @param integer	$serverId		指定serverId
	 * @return mixed
	 */
	public static function get($key, $realExpired = 0, $serverId = false) {

		$cacheDebug = self::_getInstance();

		$startTime = $cacheDebug->microtimeFloat();
		$rs = parent::get($key, $realExpired, $serverId);
		$cacheDebug->debugDetail('GET', $key, $startTime, $rs);

		return $rs;

	}

	/**
	 * 设置缓存
	 *
	 * @param string	$key		缓存key/文件名,可以是相对路径
	 * @param mixed		$value		需要缓存的数据
	 * @param integer	$expired	缓存有效期
	 * @param integer	$flag		压缩方式
	 * @param integer	$serverId	是否指定serverId
	 * @return boolean
	 */
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false) {
		global $_MooPHP;

		$cacheDebug = self::_getInstance();

		$startTime = $cacheDebug->microtimeFloat();
		$rs = parent::set($key, $value, $expired, $flag, $serverId);
		$cacheDebug->debugDetail('SET', $key, $startTime, $value);

		return $rs;

	}

	public function debugDetail($type, $key, $startTime, $value) {
		global $_MooPHP;

		$cacheDebug = self::_getInstance();

		$time = $cacheDebug->microtimeFloat() - $startTime;
		$serverId = $cacheDebug->getServerId($key);
		$arrayKey = $type.'_'.$key;
		$_MooPHP['debug']['cache'][$arrayKey]['type'] = $type;
		$_MooPHP['debug']['cache'][$arrayKey]['time'] = sprintf('%0.3f', $time * 1000);
		$_MooPHP['debug']['cache'][$arrayKey]['size'] = strlen(serialize($value));
		$_MooPHP['debug']['cache'][$arrayKey]['serverId'] = $serverId;
		$_MooPHP['debug']['cache'][$arrayKey]['server'] = $cacheDebug->config[$serverId]['host'].':'.$cacheDebug->config[$serverId]['port'];
	}

	/**
	 * 计算执行时间
	 *
	 * @return float
	 */
	public function microtimeFloat() {
		$usec = $sec = null;
		list($usec, $sec) = explode(" ", microtime());
		return ((float)$usec + (float)$sec);
	}

	public function getServerId($key) {

		$cacheDebug = self::_getInstance();

		if (!is_array($key)) {
			$serverId = intval( $key ) % $cacheDebug->serverNumber;
		} else{
			$serverId = intval( $key[0] ) % $cacheDebug->serverNumber;
		}

		return $serverId;
	}

	/**
	 * 单件
	 *
	 * @return object
	 */
	private static function _getInstance() {
		if (is_object($this) && $this instanceof MooRedisCacheDebug) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooRedisCacheDebug();
		}
		return $cache;
	}
}