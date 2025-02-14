<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooMemCache implements MooMemCacheInterface {

	// memcache缓存相关
	// 当前进程所有的memcache连接
	private $link = array();

	// memcache server 数量
	private $serverNumber = 1;

	// 压缩方式, php自带支持的 zlib 压缩数据
	private $flag = MEMCACHE_COMPRESSED;

	// 定义默认过期时间
	private $expired = 0;

	// 当前连接的serverid
	private $serverNow = -1;

	// memcache服务器和端口配置
	// $config = array();
	// $config[0] = array('host' => 'server_memcache_01.memcache.com', 'port' => 11201);
	// $config[1] = array('host' => 'server_memcache_02.memcache.com', 'port' => 11202);
	private $config;


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
	public static function config($config = array()){
		$cache = self::_getInstance();
		$cache->config = $config;
		$cache->serverNumber = count($config);
	}

	/**
	 * 设置缓存
	 *
	 * @param string	$key			缓存key/文件名,可以是相对路径
	 * @param mixed		$value			需要缓存的数据
	 * @param integer	$expired		缓存有效期
	 * @param integer	$flag			压缩方式
	 * @param integer	$serverId		是否指定serverId
	 * @return boolean
	 */
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false) {
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'set', $serverId);
		$flag = ( $flag > 0 ) ? $flag : $cache->flag;
		$expired = ( $expired > 0 ) ? $expired : $cache->expired;
		return $cache->link[$cache->serverNow]->set( $key , $value , $flag , $expired);
	}

	/**
	 * 读取缓存 方法
	 *
	 * @param string 	$key 				缓存的key
	 * @param integer	$realExpired		指定实际缓存有效期,在此接口没有实际意义，为了兼容MooCache的get接口使用
	 * @param integer	$serverId			指定serverId
	 * @return mixed
	 */
	public static function get($key,$realExpired = 0, $serverId = false) {
		static $reg = array();

		if (isset($reg[$key])) {
			return $reg[$key];
		}

		$cache = self::_getInstance();
		$cache->_selectServer($key , 'get', $serverId);
		$memValue = $cache->link[$cache->serverNow]->get($key);

		$reg[$key] = $memValue;

		return $memValue;
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
		$cache->_selectServer($key , 'delete', $serverId);
		return $cache->link[$cache->serverNow]->delete($key , $timeOut);
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
	 * @param string	$key		缓存key
	 * @param mixed		$value		需要缓存的数据
	 * @param integer	$flag		压缩方式
	 * @param integer	$expired	缓存有效期
	 * @return boolean
	 */
	public static function add($key , $value ,$flag = 0, $expired = 0) {
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'add');
		$flag = ( $flag > 0 ) ? $flag : $cache->flag;
		$expired = ( $expired > 0 ) ? $expired : $cache->expired;
		return $cache->link[$cache->serverNow]->add( $key , $value , $flag , $expired );
	}

	/**
	 * Memcache::replace 方法
	 *
	 * @param string	$key			缓存key
	 * @param mixed		$value			需要缓存的数据
	 * @param integer	$flag			压缩方式
	 * @param integer	$expired		缓存有效期
	 * @return boolean
	 */
	public static function replace($key , $value , $flag = 0 ,$expired = 0) {
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'replace');
		$flag = ( $flag > 0 ) ? $flag : $cache->flag;
		$expired = ( $expired > 0 ) ? $expired : $cache->expired;

		return $cache->link[$cache->serverNow]->replace( $key , $value , $flag , $expired );
	}

	/**
	 * Memcache::increment 方法
	 *
	 * @param string	$key
	 * @param mixed		$value
	 * @return boolean
	 */
	public static function increment($key , $value = 1) {
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'increment');
		return $cache->link[$cache->serverNow]->increment( $key , $value );
	}

	/**
	 * 设置缓存
	 *
	 * @param string	$key		缓存的key，数字开头
	 * @param mixed		$type		需要缓存的数据
	 * @param integer	$serverId	是否指定serverId
	 * @return $rs
	 */
	private function _selectServer($key = '' , $type, $serverId = false ) {
		$cache = self::_getInstance();
		if($serverId !== false){
			$serverId=$serverId % $cache->serverNumber;
		}else{
				if(!is_array($key)) {
					$serverId=intval( $key ) % $cache->serverNumber;
				}else{
					$serverId=intval( $key[0] ) % $cache->serverNumber;
				}
		}

		if( ( $cache->serverNow != $serverId ) && ( !array_key_exists( $serverId , $cache->link ) ) ) {
			$cache->link[$serverId] = new Memcache();
			$cache->link[$serverId]->connect( $cache->config[$serverId]['host'] , $cache->config[$serverId]['port'] );
		}
		$cache->serverNow = $serverId;
		if(defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
			global $_MooPHP;
			$_MooPHP['debugInfo']['cache'][] = array('key' => $key, 'mod' => $type, 'serverId' => $serverId, 'host' => $cache->config[$serverId]['host'], 'port' => $cache->config[$serverId]['port']);
		}
	}

	/**
	 * 单件
	 *
	 * @return object
	 */
	private static function _getInstance() {
		if (is_object($this) && $this instanceof MooMemCache) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooMemCache();
		}
		return $cache;
	}
}
