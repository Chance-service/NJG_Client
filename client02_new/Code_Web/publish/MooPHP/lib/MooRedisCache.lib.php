<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooRedisCache implements MooTTCacheInterface {

	// 当前进程所有的memcache连接
	private $link = array();
	
	// 注册已经使用 get方法获取过的缓存key数据
	private static $getDataReg = array();

	// memcache server 数量
	private $serverNumber = 1;

	// 压缩方式, php自带支持的 zlib 压缩数据
	// TT不支持压缩存储 
	private $flag = 0;

	// 定义默认过期时间
	private $expired = 0;

	// 当前连接的serverid
	private $serverNow = -1;

	// TT服务器和端口配置
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
	 * 设置TT的服务器和缓存类型
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
	 * @param string	$key		缓存key/文件名,可以是相对路径
	 * @param mixed		$value		需要缓存的数据
	 * @param integer	$expired	缓存有效期
	 * @param integer	$flag		压缩方式
	 * @param integer	$serverId	是否指定serverId
	 * @return boolean
	 */
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false) {
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'set', $serverId);
		$flag = 0;
		
		// 序列化并压缩
		$value = serialize($value); // 序列化
		$value = gzcompress($value); // 压缩 redis 不支持混合型数据
		
		// setex redis 设置过期时间方法
		if ($expired > 0) {
			return $cache->link[$cache->serverNow]->setex($key, $expired, $value);
		} else {
			return $cache->link[$cache->serverNow]->set($key, $value);
		}
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

		// 返回上次请求的的数据
		if (isset(self::$getDataReg[$key])) {
			return self::$getDataReg[$key];
		}

		$cache = self::_getInstance();
		$cache->_selectServer($key , 'get', $serverId);
		$value = $cache->link[$cache->serverNow]->get($key);

		// 没有数据
		if(!$value) {
			self::$getDataReg[$key] = false;
			return false;
		}
		
		// 解压
		$value = @gzuncompress($value);
		$value = unserialize($value);
		
		// 注册
		self::$getDataReg[$key] = $value;

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
		$cache->_selectServer($key , 'delete', $serverId);
		return $cache->link[$cache->serverNow]->delete($key);
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
		
		// 序列化并压缩
		$value = serialize($value); // 序列化
		$value = gzcompress($value); // 压缩 redis 不支持混合型数据
		
		return $cache->link[$cache->serverNow]->sAdd($key, $value);
	}

	/**
	 * Memcache::replace 方法
	 *
	 * @param string	$key		缓存key
	 * @param mixed		$value		需要缓存的数据
	 * @param integer	$flag		压缩方式
	 * @param integer	$expired	缓存有效期
	 * @return boolean
	 */
	public static function replace($key , $value , $flag = 0 ,$expired = 0) {
		return false;
	}

	/**
	 * Memcache::increment 方法
	 *
	 * @param string	$key
	 * @param mixed	$value
	 * @return boolean
	 */
	public static function increment($key , $value = 1) {
		return false;
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
		if ($serverId !== false) {
			$serverId = $serverId % $cache->serverNumber;
		} else {
			if (!is_array($key)) {
				$serverId = $cache->_hash2Id($key, $cache->serverNumber);
			} else{
				$serverId = $cache->_hash2Id($key[0], $cache->serverNumber);
			}
		}

		if ( ( $cache->serverNow != $serverId ) && ( !array_key_exists( $serverId , $cache->link ) ) ) {
			$cache->link[$serverId] = new Redis();
			$cache->link[$serverId]->pconnect( $cache->config[$serverId]['host'] , $cache->config[$serverId]['port']);
		}
		$cache->serverNow = $serverId;
		if (defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) {
			global $_MooPHP;
			$_MooPHP['debugInfo']['cache'][] = array('key' => $key, 'mod' => $type, 'serverId' => $serverId, 'host' => $cache->config[$serverId]['host'], 'port' => $cache->config[$serverId]['port']);
		}
	}

	/**
	 * 设置缓存
	 *
	 * @param string	$key		缓存的key，数字开头
	 * @return $id
	 */
	private function _hash2Id($key, $num) {
		$key = (string)$key;
		$key = strpos($key, '__') === false ? $key :  substr($key, 0, strpos($key, '__'));
		
		$splits = str_split($key);
		foreach ($splits as $pos=>$c) {
			if ($c != 0) {
				break;
			}
		}
		$key = substr($key, $pos);
		$sId = (ord($key[0]) + ord($key[1]) + ord($key[2])) % $num;
		return $sId;
	}


	/**
	 * 单件
	 *
	 * @return object
	 */
	private static function _getInstance() {
		if (is_object($this) && $this instanceof MooRedisCache) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooRedisCache();
		}
		return $cache;
	}
}