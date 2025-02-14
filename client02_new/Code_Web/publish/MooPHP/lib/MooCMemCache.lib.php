<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooCMemCache implements MooTTCacheInterface {

	// 当前进程所有的memcache连接
	private $link = array();

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
		$expired = ( $expired > 0 ) ? $expired : $cache->expired;

		// ttserver 是永久保存，通过保存过期时间和存入时间来兼容memcahce的自动的过期方式
		$value = array(
			'v' => $value,
			'e' => $expired,
			't'=> time()
		);

		return $cache->link[$cache->serverNow]->set($key , $value , $flag , $expired);
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

		static $reg = array();

		// 返回上次请求的的数据
		if (isset($reg[$key])) {
			return $reg[$key];
		}

		$cache = self::_getInstance();
		$cache->_selectServer($key , 'get', $serverId);
		$ttValue = $cache->link[$cache->serverNow]->get($key);

		// 没有数据
		if(!$ttValue) {
			$reg[$key] = false;
			return false;
		}

		if (!is_array($ttValue)) {
			// 清理不符合期待值的数据
			self::delete($key);
			$reg[$key] = false;
			return false;
		}

		// 数据过期处理
		// 兼容memchae的有效期写法
		// Expiration time of the item. If it's equal to zero, the item will never expire.
		// You can also use unix timestamp or a number of seconds starting from current time,
		// but in the latter case the number of seconds may not exceed 2592000 (30 days).
		// 有效期如果是大于 30天的数据，则使用认为是有效期为到的当时的时间戳
		if ($ttValue['e'] > 2592000 ) {
			$isExpired = $ttValue['e'] < time() ? true : false;
		} elseif ($ttValue['e'] > 0 && $ttValue['e'] <= 2592000) {
			$isExpired = $ttValue['t'] + $ttValue['e'] - time() <= 0 ? true : false;
		}else {
			// 永远不过期
			$isExpired = false;
		}

		// 清理过期数据
		if ($isExpired) {
			self::delete($key);
			$reg[$key] = false;
			return false;
		}

		// 如果有传入实际的过期时间
		if ($realExpired > 0) {
			// 用获取时指定的过期时间来判断
			$isExpired = $ttValue['t'] + $realExpired - time() <= 0 ? true : false;
			if ($isExpired) {
				self::delete($key);
				$reg[$key] = false;
				return false;
			}
		}

		$reg[$key] = $ttValue['v'];

		return $ttValue['v'];
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
		// ttserver 是永久保存，通过保存过期时间和存入时间来兼容memcahce的自动的过期方式
		$value = array(
			'v' => $value,
			'e' => $expired,
			't'=> time()
		);

		return $cache->link[$cache->serverNow]->add( $key , $value , $flag , $expired);
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
		$cache = self::_getInstance();
		$cache->_selectServer($key , 'replace');
		$flag = ( $flag > 0 ) ? $flag : $cache->flag;
		$expired = ( $expired > 0 ) ? $expired : $cache->expired;

		// ttserver 是永久保存，通过保存过期时间和存入时间来兼容memcahce的自动的过期方式
		$value = array(
			'v' => $value,
			'e' => $expired,
			't'=> time()
		);

		return $cache->link[$cache->serverNow]->replace( $key , $value , $flag , $expired );
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
		$cache->_selectServer($key , 'increment');
		$ttValue = $cache->link[$cache->serverNow]->get($key);

		// 返回失败
		if (!$ttValue) {
			return false;
		}

		$ttValue = unserialize($ttValue);

		if (!is_array($ttValue)) {
			return false;
		}

		$ttValue['v'] += $value;

		$cache->link[$cache->serverNow]->set($key , $ttValue , 0, $ttValue['e']);

		return  intval($ttValue['v']);
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
			$serverId=$serverId % $cache->serverNumber;
		} else {
				if (!is_array($key)) {
					$serverId = $cache->_hash2Id($key, $cache->serverNumber);
				} else{
					$serverId = $cache->_hash2Id($key[0], $cache->serverNumber);
				}
		}

		if ( ( $cache->serverNow != $serverId ) && ( !array_key_exists( $serverId , $cache->link ) ) ) {
			$cache->link[$serverId] = new Memcache();
			$cache->link[$serverId]->connect( $cache->config[$serverId]['host'] , $cache->config[$serverId]['port']);
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
		if (is_object($this) && $this instanceof MooCMemCache) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooCMemCache();
		}
		return $cache;
	}
}
