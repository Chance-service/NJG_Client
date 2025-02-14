<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooCache implements MooCacheInterface {

	//note 缓存的方式, file,  memcache(默认)
	private $cacheClassName = 'MooFileCache';


	/**
	 * 构造函数
	 *
	 */
	public function __construct() {
		// do something
	}

	/**
	 * 设置Memcache的服务器和缓存类型
	 * $config = array();
	 * $config[0] = array('host' => 'server_memcache_01.memcache.com', 'port' => 11201);
	 * $config[1] = array('host' => 'server_memcache_02.memcache.com', 'port' => 11202);
	 * @param mixed	$config
	 * @return void
	 */
	public static function config($config = array(), $cacheType = 'memcache') {
		// 缓存类型
		$cache = self::_getInstance();
		if ($cacheType == 'memcache') {
			if(defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
				$cache->cacheClassName = 'MooMemCacheDebug';
			} else {
				$cache->cacheClassName = 'MooMemCache';
			}
		} elseif ($cacheType == 'cmem') {
			if(defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
				$cache->cacheClassName = 'MooCMemCacheDebug';
			} else {
				$cache->cacheClassName = 'MooCMemCache';
			}
		} elseif ($cacheType == 'redis') {
			if(defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
				$cache->cacheClassName = 'MooRedisCacheDebug';
			} else {
				$cache->cacheClassName = 'MooRedisCache';
			}
		} else {
			if(defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
				$cache->cacheClassName = 'MooTTCacheDebug';
			} else {
				$cache->cacheClassName = 'MooTTCache';
			}
		}
		
		call_user_func(array($cache->cacheClassName, 'config'), $config);
	}

	/**
	 * 设置缓存
	 *
	 * @param string	$key			缓存key/文件名,可以是相对路径
	 * @param mixed	$value		需要缓存的数据
	 * @param integer	$expired		缓存有效期
	 * @param integer	$flag		压缩方式
	 * @param integer	$serverId		是否指定serverId
	 * @return boolean
	 */
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false) {
		self::reg($key, $value, 'set');
		$cache = self::_getInstance();
		return call_user_func_array(array($cache->cacheClassName, 'set'), array($key, $value, $expired, $flag, $serverId));
	}

	/**
	 * 读取缓存 方法
	 *
	 * @param string 	$key 缓存的key
	 * @param integer	$realExpired		指定实际缓存有效期
	 * @param integer	$serverId		指定serverId
	 * @return mixed
	 */
	public static function get($key, $realExpired = 0, $serverId = false) {

		$value = self::reg($key);
		if ($value == 'MooCacheNeedGetNew') {
			$cache = self::_getInstance();
			$value = call_user_func_array(array($cache->cacheClassName, 'get'), array($key, $realExpired, $serverId));
		}

		return $value;
	}
	
	/**
	 * 读取缓存方法(压缩)
	 *
	 * @param string 	$key 缓存的key
	 * @param integer	$realExpired		指定实际缓存有效期
	 * @param integer	$serverId		指定serverId
	 * @return mixed
	 */
	public static function setCompress($key, $value, $expired = 0, $flag = 0, $serverId = false) {
		$value = serialize($value);
		$value = gzcompress($value);
		return self::set($key, $value, $expired, $flag, $serverId);
	}
	
	/**
	 * 设置缓存(压缩)
	 *
	 * @param string	$key			缓存key/文件名,可以是相对路径
	 * @param mixed	$value		需要缓存的数据
	 * @param integer	$expired		缓存有效期
	 * @param integer	$flag		压缩方式
	 * @param integer	$serverId		是否指定serverId
	 * @return boolean
	 */
	public static function getCompress($key, $realExpired = 0, $serverId = false) {
		$value = self::get($key, $realExpired = 0, $serverId = false);
		$value = @gzuncompress($value);
		$value = unserialize($value);
		return $value;
	}

	/**
	 * 删除缓存
	 *
	 * @param string	$key			缓存key/文件名,可以是相对路径
	 * @param integer	$timeOut		超时时间
	 * @param integer	$serverId		指定serverId
	 * @return boolean
	 */
	public static function delete($key , $timeOut = 0 , $serverId = false) {
		$cache = self::_getInstance();
		return call_user_func_array(array($cache->cacheClassName, 'delete'), array($key, $timeOut, $serverId));
	}


	/**
	 * delete别名，向下兼容
	 *
	 */
	public static function clean($key , $timeOut = 0 , $serverId = false) {
		return self::delete($key , $timeOut, $serverId);
	}

	/**
	 * Memcache::add 方法
	 *
	 * @param string	$key			缓存key
	 * @param mixed	$value		需要缓存的数据
	 * @param integer	$flag		压缩方式
	 * @param integer	$expired		缓存有效期
	 * @return boolean
	 */
	public static function add($key , $value ,$flag = 0, $expired = 0) {
		$cache = self::_getInstance();
		return call_user_func_array(array($cache->cacheClassName, 'add'), array($key, $value, $flag, $serverId));
	}

	/**
	 * Memcache::replace 方法
	 *
	 * @param string	$key			缓存key
	 * @param mixed	$value		需要缓存的数据
	 * @param integer	$flag		压缩方式
	 * @param integer	$expired		缓存有效期
	 * @return boolean
	 */
	public static function replace($key , $value , $flag = 0 ,$expired = 0) {
		$cache = self::_getInstance();
		return call_user_func_array(array($cache->cacheClassName, 'replace'), array($key, $value, $flag, $expired));
	}

	/**
	 * Memcache::increment 方法
	 *
	 * @param string	$key
	 * @param mixed	$value
	 * @return boolean
	 */
	public static function increment($key , $value = 1) {
		$cache = self::_getInstance();
		return call_user_func_array(array($cache->cacheClassName, 'increment'), array($key, $value));
	}

	/**
	 * 注册get数据
	 *
	 * @param string	$key
	 * @param string	$value
	 * @param string	$method 
	 * @return mixed
	 */
	private static function reg($key, $value = '', $method = 'get') {

		static $reg = array();

		// 返回上次请求的的数据
		if ($method == 'get') {
			if (isset($reg[$key])) {
				return $reg[$key];
			} else {
				return 'MooCacheNeedGetNew';
			}
		} else {
			$reg[$key] = $value;
			return true;
		}
	}


	/**
	 * 单件
	 *
	 * @return object
	 */
	private static function _getInstance() {
		if (is_object($this) && $this instanceof MooCache) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooCache();
		}
		return $cache;
	}
}
