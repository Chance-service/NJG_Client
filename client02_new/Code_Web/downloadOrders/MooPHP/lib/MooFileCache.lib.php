<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

final class MooFileCache implements MooFileCacheInterface {

	//  默认的缓存保存目录
	private $cacheDir = '/tmp/cache';

	//note 缓存文件后缀
	const FILE_SUFFIX = '.cache.php';

	/**
	 * 构造函数
	 *
	 */
	public function __construct() {
		if (!defined('MOOCACHE_CACHE_DIR')) {
			exit('ERROR: You must define cache dir first');
		}

		$cacheDir = MOOCACHE_CACHE_DIR;
		if ($cacheDir) {
			if (!MooFile::isExists($cacheDir)) {
				MooFile::mkDir($cacheDir);
			}
			$this->cacheDir = $cacheDir;
		}
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
	public static function set($key, $data, $expired = 0) {

		$filePath = self::_getFilePath($key);
		$cacheData = array();
		$cacheData['data'] = $data;
		$cacheData['createTime'] = time();
		$cacheData['expired'] = $expired;

		return MooFile::write($filePath, serialize($cacheData));
	}

	/**
	 * 读取缓存 方法
	 *
	 * @param string 	$key 			缓存的key
	 * @param integer	$realExpired	指定实际缓存有效期
	 * @param integer	$serverId		指定serverId
	 * @return mixed
	 */
	public static function get($id, $realExpired=0) {

		static $reg = array();

		if ($reg[$id]) {
			return $reg[$id];
		}

		$filePath = self::_getFilePath($id);

		// 如果文件不存在
		if (!MooFile::isExists($filePath)) {
			return false;
		}


		// 包含缓存数据文件
		$data = unserialize(MooFile::readAll($filePath));

		// 判断数据是否超时, 增加如果expired为 0 的时候，有效期为永久
		if ($data['expired'] >0) {
			$expired = $data['createTime'] + $data['expired'] - time();
			if ($expired < rand(0, 600)) {
				return false;
			}
		}

		// 如果有传入实际的过期时间
		if ($realExpired > 0) {
			// 用获取时指定的过期时间来判断
			$expired = $data['createTime'] + $realExpired - time();
			if ($expired < rand(0, 600)) {
				return false;
			}
		}
		$reg[$id] = $data['data'];

		return $data['data'];
	}

	/**
	 * 删除缓存
	 *
	 * @param string	$key			缓存key/文件名,可以是相对路径
	 * @param integer	$timeOut		超时时间
	 * @param integer	$serverId		指定serverId
	 * @return boolean
	 */
	public static function delete($key) {
		$cache = self::_getInstance();
		$filePath = self::_getFilePath($key);
		return MooFile::rm($filePath);
	}


	/**
	 * delete别名，向下兼容
	 *
	 */
	public static function clean($key) {
		return self::delete($key);
	}


	/**
	 * 根据ID，生成cache的数据文件dataFile(存贮缓存数据)
	 *
	 * @param string $id
	 */
	private static function _getFilePath($id) {
		$cache = self::_getInstance();

		if (!$cache->cacheDir || !MooFile::isExists($cache->cacheDir)) {
			exit('ERROR: You must create cache dir first');
		}

		// 如果没有定义目录，则根据id的前四个字母来划分目录
		if (false === strpos($id, '/')) {
			$md5 = md5($id);
			$id = 'other/' . substr($id, 0, 3) . '/' . ord($md5[0]) . '/' . ord($md5[1]) . '/' . $id;
		}
		return $cache->cacheDir . '/' . $id . self::FILE_SUFFIX;
	}

	/**
	 * 单件
	 *
	 * @return object
	 */
	private static function _getInstance() {
		if (is_object($this) && $this instanceof MooFileCache) {
			return $this;
		}
		static $cache = null;
		if (!$cache) {
			$cache = new MooFileCache();
		}
		return $cache;
	}
}
