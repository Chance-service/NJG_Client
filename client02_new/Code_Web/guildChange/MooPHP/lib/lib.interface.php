<?php

/**
 * DB类的公共接口定义
 *
 */
interface MooDBInterface {
	public function setData($key, $value);
	public function setExpr($key, $value);
	public function insert($table, $exit = true);
	public function update($table, $pk, $id, $exit = true, $limit = false);
	public function delete($table, $pk, $id, $exit = true, $limit = false);
	public function getInsertId();
	public function getAll($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getCol($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getRow($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getOne($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getPage($sql, $param = array(), $rows = 20, $links = 10, $exit = true, $cache = 0, $totalCache = 0);
	public function begin();
	public function rollback();
	public function commit();
	public function query($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getError();
}

interface MooDBStatementInterface {
	public function fetch();
	public function fetchAll();
	public function fetchCol($col = 0);
	public function rowCount();
}

/**
 * DBTable类的公共接口定义
 *
 */
interface MooDBTableInterface {
	public function __construct();
	public function getInsertId();
	public function getError();
	public function getAll($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getRow($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getOne($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function getPage($sql, $param = array(), $rows = 20, $links = 10, $exit = true, $cache = 0, $totalCache = 0);
	public function getCol($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function query($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '');
	public function setData($key, $value);
	public function setExpr($key, $value);
	public function insert($exit = true);
	public function update($id, $pk = '', $exit = true);
	public function delete($id, $pk = '', $exit = true);
	public function load($id, $pk = '', $useReg = true, $exit = true);
}

/**
 * 数据对象的接口
 * @author machinema
 *
 */
interface MooDaoObjInterface {
	public function set($k, $v);
	public function getData();
	public function getError();
	public function update($exit = true);
	public function delete($exit = true);
}

/**
 * DBPagin类的公共接口定义
 *
 */
interface MooDBPaginInterface {
	static public function setLinks($linkNum);
	static public function setRows($perPage);
	static public function getPage($dbh, $sql, $param = array(), $exit = true);
}

/**
 * Cache类的公共接口定义
 *
 */
interface MooCacheInterface {
	public static function config($config = array(), $cacheType = 'memcache');
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false);
	public static function get($key, $realExpired = 0, $serverId = false);
	public static function delete($key , $timeOut = 0 , $serverId = false);
	public static function clean($key , $timeOut = 0 , $serverId = false);
	public static function add($key , $value ,$flag = 0, $expired = 0);
	public static function replace($key , $value , $flag = 0 ,$expired = 0);
	public static function increment($key , $value = 1);
}

/**
 * 文件Cache类的公共接口定义
 *
 */
interface MooFileCacheInterface {
	public static function set($key, $value, $expired = 0);
	public static function get($key, $realExpired = 0);
	public static function delete($key);
	public static function clean($key);
}

/**
 * MemCache类的公共接口定义
 *
 */
interface MooMemCacheInterface {
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false);
	public static function get($key, $realExpired = 0, $serverId = false);
	public static function delete($key , $timeOut = 0 , $serverId = false);
	public static function clean($key , $timeOut = 0 , $serverId = false);
	public static function add($key , $value ,$flag = 0, $expired = 0);
	public static function replace($key , $value , $flag = 0 ,$expired = 0);
	public static function increment($key , $value = 1);
}

/**
 * Tokyo Cabinet(Tokyo Tyrant)Cache类的公共接口定义
 *
 */
interface MooTTCacheInterface {
	public static function set($key, $value, $expired = 0, $flag = 0, $serverId = false);
	public static function get($key, $realExpired = 0, $serverId = false);
	public static function delete($key , $timeOut = 0 , $serverId = false);
	public static function clean($key , $timeOut = 0 , $serverId = false);
	public static function add($key , $value ,$flag = 0, $expired = 0);
	public static function replace($key , $value , $flag = 0 ,$expired = 0);
	public static function increment($key , $value = 1);
}


/**
 * Config类的公共接口定义
 *
 */
interface MooConfigInterface {
	public static function get($keyName);
	public static function set($configDir);
}

/**
 * Cookie类公共接口
 */
interface MooCookieInterface {
	static public function set($key, $value, $expire = 0, $secure = false);
	static public function get($name);
	static public function remove($name);
}

/**
 * File类的公共接口定义
 *
 */
interface MooFileInterface {
	static public function mkDir($aimUrl);
	static public function touch($aimUrl, $overWrite = false);
	static public function mv($filePath, $aimPath, $overWrite = false);
	static public function cp($filePath, $aimPath, $overWrite = false);
	static public function rm($filePath);
	static public function isDir($path);
	static public function isExists($path);
	static public function write($file, $content, $append = false);
	static public function readLine($file, $size = 4096);
	static public function readAll($file);
}

/**
 * Form类的公共接口定义
 *
 */
interface MooFormInterface {
	static public function get();
	static public function post();
	static public function request();
	static public function isSubmit($btn = null);
}

/**
 * Session类的公共接口
 */
interface MooSessionInterface {
	static public function set($key, $value);
	static public function get($key);
	static public function remove($key);
	static public function start();
}

/**
 * View类的公共接口定义
 *
 */
interface MooViewInterface {
	static public function cache($timeout = -1);
	static public function set($item1, $item2 = '');
	static public function fetch($tpl);
	static public function render($tpl);
}

/**
 * Pagin类接口定义
 *
 */
interface MooPaginInterface {
	static public function getPage($pg, $total, $perPage = 20, $linkNum = 10);
}

/**
 * Logger类的公共接口定义
 *
 */
interface MooLogInterface {
	static public function setNameFormat($logNameFormat);
	static public function write($msg, $flag = '');
	static public function error($msg);
	static public function show($msg);
	static public function tee($msg, $flag = '');
}

/**
 * 上传类的公共接口定义
 *
 */
interface MooUploadInterface {
	static public function put($FILE);
	static public function getError();
	static public function parse();
}

/**
 * Validate类公共接口
 */
interface MooValidateInterface {
	static public function isEmail($email);
	static public function isInt($int);
	static public function isFloat($float);
	static public function isAlnum($alnum);
	static public function isPunct($punct);
	static public function isAlpha($alpha);
	static public function isDate($date, $format = NULL);
	static public function isBetween($value, $from, $to);
	static public function isStrLength($value, $min = 0, $max = NULL);
	static public function isPostcode($postcode);
	static public function isMobile($mobile);
}

/**
 * Language类的公共接口定义
 *
 */
interface MooLanguageInterface {
	static public function set($key, $value='');
	static public function setLocation($location);
	public static function get($keyName);
}