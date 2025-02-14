<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 数据库操作类
 * 
 * expample:
 * 
 * // 获取一行数据(第一个参数是sql；第二个参数是sql编译；第三个参数是控制发生错误的时候是否强制退出，默认是true，即强制退出)
 * $dbh->getRow('SELECT * FROM table WHERE id = :id', array('id' => "m'a"), false);
 * $dbh->getRow("SELECT * FROM table WHERE id = 'm\'a'", NULL, false);
 * 
 * // 获取一列数据
 * $dbh->getCol('SELECT id FROM table WHERE id = :id', array('id' => "m'a"), true);
 * $dbh->getCol("SELECT id FROM table WHERE id = 'm\'a'");
 * 
 * // 获取所有数据
 * $dbh->getAll('SELECT * FROM table' WHERE id = :id', array('id' => "m\'a"));
 * $dbh->getAll("SELECT * FROM table' WHERE id = 'm\'a'");
 * 
 * // 获取一个数据
 * $dbh->getOne('SELECT id FROM table');
 * 
 * // 发送一条sql
 * $dbh->query('UPDATE table SET name = :name WHERE id = :id', array('name' => "a'b'c", 'id' => "m'a"), true);
 * $dbh->query("UPDATE table SET name = 'a\'b\'c' WHERE id = 'm\'a'");
 * 
 * // 获取最近一次错误
 * $err = $dbh->getError();
 * 
 * // 获得上次插入的id
 * $dbh->query('INSERT INTO table');
 * $id = $dbh->getInsertId();
 * 
 * // 用query发送查询，返回select对象
 * $query = $dbh->query('SELECT * FROM table', null, true, 3600);
 * while ($rs = $query->fetch()) {
 * 		print_r($rs);
 * }
 */
class MooDB implements MooDBInterface {
	private $db;
	private $conn;
	private $error = '';
	private $errDir = '';
	private $char = '';
	private $insertId = 0;
	protected $config = array();
	private $data = array();

	const USE_CACHE = 'USE_CACHE';

	/**
	 * 构造函数，
	 * 本构造函数逻辑上不允许被重载，但是由于特殊的DBDebug需要重载这个类，因此没有作final限制。
	 *
	 * @param string $hostname	主机
	 * @param string $username	用户名
	 * @param string $password	密码
	 * @param string $dbname	数据库
	 * @param string $errDir	错误日志目录
	 * @param int $cacheLimit	允许缓存的最大条数
	 * @return MooDB
	 */
	public function __construct($hostname, $username, $password, $dbname, $char, $errDir, $cacheLimit = 1000, $pconnect = false, $selectDb = true) {
		$config = array();
		$config['hostname'] = $hostname;
		$config['username'] = $username;
		$config['password'] = $password;
		$config['dbname']	= $dbname;
		$config['char']		= $char;
		$config['cacheLimit']	= $cacheLimit;
		$config['pconnect']	= $pconnect;
		$config['selectDb']	= $selectDb;
		$this->config = $config;

		$this->errDir = $errDir;
	}
	
	/**
	 * 设置更新数据
	 *
	 * @param string $key
	 * @param string $value
	 */
	final public function setData($key, $value) {
		$this->data[$key][] = array('value' => $value, 'type' => 'setData');
	}
	
	/**
	 * 设置更新数据(表达式)
	 *
	 * @param string $key
	 * @param string $value
	 */
	final public function setExpr($key, $value) {
		$this->data[$key][] = array('value' => $value, 'type' => 'setExpr');
	}

	/**
	 * 向某表中添加一条数据
	 * 本函数不允许被重载
	 *
	 * @param string	$table	表名
	 * @param boolean	$exit	当发生错误时是否中断程序
	 * @return boolean
	 */
	final public function insert($table, $exit = true) {
		$data = $this->data;
		$this->data = array();

		if (count($data) == 0) {
			return false;
		}
		
		$colStr = $valueStr = '';
		$param = array();
		foreach ($data as $k => $row) {
			if ($row[0]['type'] == 'setData') {
				$colStr .= ",`{$k}`";
				$valueStr .= ",:{$k}";
				$param[$k] = $row[0]['value'];
			} else {
				$colStr .= ",`{$k}`";
				$valueStr .= ", {$row[0]['value']}";
			}
		}
		$colStr = substr($colStr, 1);
		$valueStr = substr($valueStr, 1);

		$sql = "INSERT INTO `$table`($colStr) VALUES($valueStr)";
		$rs = (boolean)$this->query($sql, $param, $exit);
		if (!$rs) {
			$this->insertId = 0;
		}
		return $rs;
	}

	/**
	 * 向某表中添加一条数据
	 * 本函数不允许被重载
	 *
	 * @param string	$table	表名
	 * @param boolean	$exit	当发生错误时是否中断程序
	 * @return boolean
	 */
	final public function insertOrUpdate($table, $exit = true) {
		$data = $this->data;
		$this->data = array();

		if (count($data) == 0) {
			return false;
		}
		
		$valueStr = '';
		$param = array();
		foreach ($data as $k => $row) {
			if ($row[0]['type'] == 'setData') {
				$valueStr .= ",`$k` = :{$k}";
				$param[$k] = $row[0]['value'];
			} else {
				$valueStr .= ",`$k` = {$row[0]['value']}";
			}
		}
		$valueStr = substr($valueStr, 1);

		$sql = "INSERT INTO `$table` SET $valueStr ON DUPLICATE KEY UPDATE $valueStr";
		$rs = (boolean)$this->query($sql, $param, $exit);
		if (!$rs) {
			$this->insertId = 0;
		}
		return $rs;
	}
	
	/**
	 * 根据主键更新某表中的数据
	 * 本函数不允许被重载
	 *
	 * @param string	$table	表名
	 * @param array		$data	入库的数据
	 * @param mix		$id		主键值
	 * @param string	$pk		主键名
	 * @param boolean	$exit	当发生错误时是否中断程序
	 * @param int		$limit	限制更新的条数
	 * @return boolean
	 */
	final public function update($table, $pk, $id, $exit = true, $limit = false) {
		$data = $this->data;
		$this->data = array();

		if (count($data) == 0) {
			return false;
		}

		if (!is_array($id)) {
			$where = "`{$pk}` = " . $this->_quote($id);
		} else {
			$where = array();
			foreach ($id as $k => $v) {
				$where[] = "{$k} = " . $this->_quote($v);
			}
			$where = implode(' AND ', $where);
		}
		
		$valueStr = '';
		$param = array();
		$i = 0;
		foreach ($data as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setData') {
					$i++;
					$valueStr .= ",`{$k}` = :{$k}_{$i}";
					$param["{$k}_{$i}"] = $v['value'];
				} else {
					$valueStr .= ",`$k` = {$v['value']}";
				}
			}
		}
		$valueStr = substr($valueStr, 1);

		$sql = "UPDATE `{$table}` SET $valueStr WHERE $where";
		$limit ? $sql .= ' LIMIT ' . intval($limit) : false;
		return (boolean)$this->query($sql, $param, $exit);
	}

	/**
	 * 根据主键删除某表中的数据
	 *
	 * @param string	$table	表名
	 * @param mix		$id		主键值
	 * @param string	$pk		主键名
	 * @param boolean	$exit	当发生错误时是否中断程序
	 * @param int		$limit	限制删除的条数
	 * @return boolean
	 */
	final public function delete($table, $pk, $id, $exit = true, $limit = false) {
		if (!is_array($id)) {
			$where = "`{$pk}` = " . $this->_quote($id);
		} else {
			$where = array();
			foreach ($id as $k => $v) {
				$where[] = "{$k} = " . $this->_quote($v);
			}
			$where = implode(' AND ', $where);
		}

		$sql = "DELETE FROM `{$table}` WHERE $where";
		$limit ? $sql .= ' LIMIT ' . intval($limit) : false;
		return (boolean)$this->query($sql, null, $exit);
	}

	/**
	 * 取出最近一次插入的id
	 *
	 * @return int
	 */
	final public function getInsertId() {
		$insertId = @mysql_insert_id($this->conn);
		//当自增值大于int的最大值 2147483647 时候，需要用后一种方式(详见mysql手册)获得自增id
		$insertId = $insertId >= 0 ? $insertId : $this->getOne("SELECT last_insert_id()");

		if ($insertId) {
			$this->insertId = $insertId;
		}

		return $this->insertId;
	}

	/**
	 * 返回查询的所有结果
	 *
	 * @param string	$sql
	 * @param array		$param
	 * @param boolean	$exit
	 * @return array
	 */
	final public function getAll($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		// 执行SQL
		$res = $this->query($sql, $param, $exit, $cache, $cacheDir);
		if (!is_object($res)) {
			return false;
		}
		return $res->fetchAll();
	}

	/**
	 * 返回查询结果的第一列
	 *
	 * @param string	$sql
	 * @param array		$param
	 * @param boolean	$exit
	 * @param int		$cache
	 * @return array
	 */
	final public function getCol($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$res = $this->query($sql, $param, $exit, $cache, $cacheDir);
		if (!is_object($res)) {
			return false;
		}
		return $res->fetchCol();
	}

	/**
	 * 返回查询结果的第一行
	 *
	 * @param string	$sql
	 * @param array		$param
	 * @param boolean	$exit
	 * @param int		$cache
	 * @return array
	 */
	final public function getRow($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$sql = $sql . ' LIMIT 1';
		$res = $this->query($sql, $param, $exit, $cache, $cacheDir);
		if (!is_object($res)) {
			return false;
		}
		$rs = $res->fetch();
		return $rs;
	}

	/**
	 * 返回查询结果的第一个值
	 *
	 * @param string	$sql
	 * @param array		$param
	 * @param boolean	$exit
	 * @param int		$cache
	 * @return string
	 */
	final public function getOne($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$rs = $this->getRow($sql, $param, $exit, $cache, $cacheDir);
		if ($rs === false) {
			return false;
		} elseif (is_array($rs)) {
			return current($rs);
		} else {
			return null;
		}
	}
	
	/**
	 * 获取分页数据
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @param int $totalCache
	 * @param int $rows
	 * @param int $links
	 * @return array
	 */
	public function getPage($sql, $param = array(), $rows = 20, $links = 10, $exit = true, $cache = 0, $totalCache = 0) {
		MooDBPagin::setRows($rows);
		MooDBPagin::setLinks($links);
		return MooDBPagin::getPage($this, $sql, $param, $exit, $cache, $totalCache);
	}

	/**
	 * 开启事务
	 *
	 */
	final public function begin() {
		return (boolean)$this->query('START TRANSACTION', null, true);
	}

	/**
	 * 回滚事物
	 *
	 */
	final public function rollback() {
		return (boolean)$this->query('ROLLBACK', null, true);
	}

	/**
	 * 执行事物
	 *
	 */
	final public function commit() {
		return (boolean)$this->query('COMMIT', null, true);
	}

	/**
	 * 准备执行一条SQL
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @return mixed
	 */
	public function query($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$cache = intval($cache);

		// 判断是否是SELECT操作
		$isSelect = !preg_match('/\s*(UPDATE|DELETE|INSERT)\s*/i', $sql);

		// 配置SQL
		$sql = $this->_prepare($sql, $param);

		// 如果是SELECT操作，则判断是否需要使用缓存
		if ($cache && $isSelect) {
			$sqlHash = md5($sql);
			$cacheDir && $cacheDir .= '/';
			$sqlHash = 'sqlCache/' . $cacheDir . ord($sqlHash[0]) . '/' . ord($sqlHash[1]) . '/' . $sqlHash;
			// 如果缓存文件存在，则直接从缓存文件中读取文件
			$cacheData = MooCache::get($sqlHash);
			if ($cacheData) {
				$cacheData == 'NODATA' && $cacheData = array();
				return new MooDBStatement($this->conn, $cache, $cacheData, $sqlHash, $this->config['cacheLimit']);
			}
		}

		$rs = $this->sendQuery($sql, $exit);

		// 判断是不是select操作，如果是，则返回MooDBStatement对象
		if (is_resource($rs)) {
			return new MooDBStatement($this->conn, $cache, $rs, $sqlHash, $this->config['cacheLimit']);
		}
		return $rs;
	}

	/**
	 * 向mysql发送query
	 *
	 * @param string $sql
	 * @return mix
	 */
	protected function sendQuery($sql, $exit) {
		static $tryNum = 0;

		// 判断如果当前没有连接的话，则需要建立连接
		if (!$this->conn) {
			// 如果重试次数超过3次，则放弃重试
			if ($tryNum > 3) {
				$tryNum = 0;
				return false;
			}
			$tryNum++;
			$this->_connect();
			$this->config['selectDb'] && $this->_selectDB();
		}

		// 发送SQL
		$rs = @mysql_query($sql, $this->conn);

		// 如果返回错误，并且是因为丢失连接造成的话，则需要重新连接
		if (!$rs) {
			$this->error = @mysql_error($this->conn);
			if (@!mysql_ping($this->conn)) {
				$this->conn = null;
				return $this->sendQuery($sql, $exit);
			} else {
				$this->_error($this->error, $exit);
	
				// 判断是否为insert操作,如果是，则清除insertId
				if (preg_match('/^\s*INSERT\s+INTO/i', $sql)) {
					$this->insertId = 0;
				}
			}
		} else {
			$this->error = '';
			$tryNum = 0;
		}
		return $rs;
	}

	/**
	 * 获取最近一次错误信息
	 *
	 * @return string
	 */
	final public function getError() {
		return $this->error;
	}


	/**
	 * 返回数据库名字
	 *
	 * @param string $dbname
	 */
	public function getDbName() {
		return $this->config['dbname'];
	}

	/**
	 * 编译sql语句
	 *
	 * @param string $sql
	 * @param array $param
	 * @return string
	 */
	final protected function _prepare($sql, $param) {
		static $i = 0;
		if (!$param) {
			return $sql;
		}

		$key = $value = $keys = array();
		foreach ($param as $k => $v) {
			$keys[$k] = strlen($k);
		}
		arsort($keys);
		foreach ($keys as $k => $v) {
			$key[] = ':' . $k;
			if (!is_array($param[$k])) {
				$value[] = $this->_quote($param[$k]);
			} else {
				if (count($param[$k]) > 0) {
					foreach ($param[$k] as $itemK => $itemV) {
						$param[$k][$itemK] = $this->_quote($itemV);
					}
					$value[] = implode(", ", $param[$k]);
				} else {
					$value[] = "''";
				}
			}
		}

		// 编译SQL
		if ($key && $value) {
			$sql = str_replace($key, $value, $sql);
		}
		return $sql;
	}

	/**
	 * 转义操作
	 *
	 * @param mix $value
	 * @return mix
	 */
	final private function _quote($value) {
		$value = addslashes($value);
		$value = is_string($value) ? "'{$value}'" : $value;
		return $value;
	}

	/**
	 * 记录错误信息
	 *
	 * @param string $msg
	 */
	final private function _recordError($msg) {
		$flag = "\t|-|\t";
		$error = $this->error;
		$msg = $error ? str_replace(array("\r", "\n", "\t", '  '), ' ', $error) : $msg;
		$ip = $_SERVER['SERVER_ADDR'] ? $_SERVER['SERVER_ADDR'] : '0.0.0.0';
		$log = "<[" . date('Y-m-d H:i:s') . "]>{$flag}";
		$log .= "<[$ip]>{$flag}";
		$log .= "<[$msg]>{$flag}";
		$log .= "<[From:";

		// 记录错误发生的过程
		$bugInfo = debug_backtrace();
		unset($bugInfo[0]);
		unset($bugInfo[1]);
		krsort($bugInfo);
		foreach ($bugInfo as $row) {
			foreach ($row['args'] as $k => $v) {
				is_object($v) ? $v = 'object' : false;
				$row['args'][$k] = str_replace(array("\r", "\n", "\t", '  '), ' ', (string)$v);
			}
			$file = basename($row['file']);
			$args = implode(', ', $row['args']);
			$log .= " {$file}-L{$row['line']} {$row['class']}{$row['type']}{$row['function']}($args);;";
		}
		$log .= "]>\n";

		$errFile = $this->errDir . '/' . date('Ymd') . '.error.php';
		MooFile::write($errFile, $log, true);
	}

	/**
	 * 提示错误，并将错误保存到错误日志中
	 *
	 * @param string $msg
	 * @param string $error
	 */
	final private function _error($msg, $exit = true) {
		// 如果日志目录存在的话，则记录错误日志
		$this->_recordError($msg);

		// 判断是否要中断程序
		if ($exit) {
			$this->_exit($msg);
		}
	}

	/**
	 * 退出程序,并输出提示信息
	 *
	 * @param string $msg
	 */
	protected function _exit($msg) {
		exit('DB ERROR.');
	}


	/**
	 * 连接数据库
	 *
	 */
	private function _connect() {

		// 存放已经链接好的资源
		static $regResouce = array();

		// 关闭不正确的的资源链接
		if ($this->conn != NULL && !$this->config['pconnect']) {
			@mysql_close($this->conn);
			unset($this->conn);
		}

		// 开启了pconnect 或者关闭selectDb的话需要保存已经链接好的资源
		// 如果开启了 pconnect ，需要关注下面几个参数
		// pm.max_children = 5, 最多的子子进程数目 （php）
		// pm.max_requests = 100, php的刷新进程的累积处理的请求数目 （php）
		// max_connections =500,  mysql 最大连接数,包括 正在 sleep的链接和正在处理的链接
		// wait_timeout=600;  mysql链接过期时间，如果过了此时间，mysql会kill掉相应的mysql链接
		// 在一个php进程被重新刷新的时候，mysql的pconnect就会在web端被释放，但无法向mysql发释放的信号或者因为版本不一致等，发了mysql那边无法响应
		// 所以 php进程刷新的时间和wait_timeout时间是无限接近是理想的完美状态，但最好是 php进程刷新的时间必须是<= wait_timeout
		// 如果 php进程刷新的时间 远远小于 wait_timeout， 那么mysql就会有很多 sleep链接，mysql很快就会达到 max_connections而挂掉
		// 如果  wait_timeout< php进程刷新的时间, 那么会导致msyql链接出现 2006或者2003错误，而且资源也不能重复利用,也有可能造成mysql挂掉
		// 编译php必须使用mysql提供的，并且最好和mysql server版本一致的lib来编译php的mysql链接lib，否则会出现 tcp链接 close_wait 状态的过多，而导致web这边网络资源问题
		$resKey = md5($this->config['hostname'] . $this->config['username'] . $this->config['password']);
		if (($this->config['pconnect'] || !$this->config['selectDb']) && isset($regResouce[$resKey]) && $regResouce[$resKey]) {
			$this->conn = $regResouce[$resKey];
			return true;
		}

		// pconnect 会使用一个 3次握手后，获得的唯一链接，实例化不同的db的时候，无需3次握手，但也会有相应的tcp传输过程
		if ($this->config['pconnect']) {
			$this->conn = @mysql_pconnect($this->config['hostname'], $this->config['username'], $this->config['password']);
			// 正常获取资源后，保存相应的资源
			$this->conn && $regResouce[$resKey] = $this->conn;

		} else {
			// 如果打开了 selectDb，那么则需要每次返回新的链接资源，则 newLink 必须为 true
			$this->conn = @mysql_connect($this->config['hostname'], $this->config['username'], $this->config['password'], $this->config['selectDb']);
			// 如果关闭了 selectDb，那么久需要把链接保存到 静态变量$regResouce里面，给后续备用
			!$this->config['selectDb'] && $this->conn && $regResouce[$resKey] = $this->conn;
		}

		if (!$this->conn) {
			$this->_error('Can\'t connecting error.' . mysql_errno(), true);
		}

		$this->_setChar();
	}

	/**
	 * 选择数据库
	 *
	 */
	private function _selectDB() {
		$db = @mysql_select_db($this->config['dbname'], $this->conn);
		if (!$db) {
			$this->_error('DB not exists error.', true);
		}
	}

	/**
	 * 设置字符集
	 *
	 */
	private function _setChar() {
		if ($this->config['char']) {
			$this->query('SET NAMES ' . $this->config['char']);
		}
	}
}

/**
 * select 对象
 *
 */
class MooDBStatement implements MooDBStatementInterface {
	private $conn;
	private $cache;
	private $res;
	private $resType;
	private $resCount;
	private $cacheId;
	private $cacheLimit;

	/**
	 * 构造函数
	 *
	 * @param mix $res
	 * @param string $cacheId
	 * @param int $cacheLimit
	 */
	function __construct($conn, $cache, $res, $cacheId, $cacheLimit) {
		$this->conn = $conn;
		$this->res = $res;
		$this->cache = $cache;
		$this->cacheLimit = $cacheLimit < 500 ? 500 : intval($cacheLimit);

		// 如果是数组，则说明是缓存数据；如果是资源，则说明是mysql返回的数据
		if (is_array($this->res)) {
			$this->resType = 'ARRAY';
			$this->resCount = @count($this->res);
		} elseif (is_resource($this->res)) {
			$this->resType = 'RESOURCE';
			// 如果需要缓存，则需要事先知道本次查询返回多少条记录，如果太多，则不可以缓存。主要是担心内存不够
			// 如果业务上不需要知道有多少条数据的时候，这里可能会有一些多余的开销。但是在这里，这个开销是不可避免的
			if ($cacheId) {
				$this->resCount = @mysql_affected_rows($this->conn);
			}
		}
		$this->cacheId = $cacheId;
	}

	/**
	 * 获取返回资源类型：数组或者资源
	 *
	 * @return string
	 */
	public function getResType() {
		return $this->resType;
	}

	/**
	 * 遍历mysql返回的句柄
	 *
	 * @param resource $res
	 * @param string $type
	 * @return array
	 */
	final public function fetch() {
		if ($this->resType == 'ARRAY') {
			// 从缓存中弹出数据
			$rs = array_shift($this->res);
			return $rs ? $rs : null;
		} elseif ($this->resType == 'RESOURCE') {
			$rs = @mysql_fetch_assoc($this->res);
			// 如果没有定义缓存，或者数据条数超过允许的缓存条数，则直接返回，不记录缓存
			if (!$this->cacheId || $this->resCount > $this->cacheLimit) {
				return $rs ? $rs : null;
			}
			
			static $data = array();
			static $i = 0;
			$i++;
			// 否则需要记录缓存数据
			if ($rs) {
				$data[] = $rs;
			}

			// 当所有数据遍历结束时，将数据缓存到文件中
			if ($i >= $this->resCount) {
				MooCache::set($this->cacheId, $data ? $data : 'NODATA', $this->cache);
				unset($this->cacheId);
				// 清空数据
				$data = array();
				$i = 0;
				$this->freeResult();
			}
			return $rs ? $rs : null;
		} else {
			return false;
		}
	}

	/**
	 * 返回所有查询结果
	 *
	 * @return array
	 */
	final public function fetchAll() {
		if ($this->resType == 'ARRAY') {
			// 直接返回缓存数据
			$return = $this->res;

			// 清空对象中保存的数组
			$this->freeResult();
			return $return;
		} elseif ($this->resType == 'RESOURCE') {
			$data = array();
			while (false != ($rs = $this->fetch())) {
				$data[] = $rs;
			}
			
			return $data;
		} else {
			return false;
		}
	}

	/**
	 * 返回一列查询结果
	 *
	 * @return array
	 */
	final public function fetchCol($col = 0) {
		$col = is_int($col) ? (int)$col : (string)$col;
		if ($this->res === false) {
			return false;
		}
		if ($this->resType == 'ARRAY') {
			$data = array();
			$keys = null;
			// 直接返回缓存数据
			foreach ($this->res as $row) {
				if (!$col) {
					$data[] = current($row);
				} elseif ($row[$col]) {
					$data[] = $row[$col];
				} else {
					// 如果$col不在$row中(一般这个时候$col是数字类型)，
					// 那么则需要先取出所有字段，然后取出第$col列对应的字段名称，然后在取得数据
					$keys ? false : $keys = array_keys($row);
					$data[] = $row[$keys[$col]];
				}
			}
			// 清空对象中保存的数组
			$this->freeResult();
			return $data;
		} elseif ($this->resType == 'RESOURCE') {
			$data = $dataAll = array();
			while (false != ($rs = $this->fetch($this->res))) {
				$dataAll[] = $rs;
				if (!$col) {
					$data[] = current($rs);
				} elseif ($rs[$col]) {
					$data[] = $rs[$col];
				} else {
					$keys ? false : $keys = array_keys($rs);
					$data[] = $rs[$keys[$col]];
				}
			}

			// 清空对象中保存的资源
			$this->freeResult();
			return $data;
		} else {
			return false;
		}
	}

	/**
	 * 取出影响列数
	 *
	 * @return int
	 */
	final public function rowCount() {
		if ($this->resType == 'ARRAY') {
			return (int)$this->resCount;
		} elseif ($this->resType == 'RESOURCE') {
			return $this->resCount ? $this->resCount : (int)@mysql_affected_rows($this->conn);
		} else {
			return 0;
		}
	}

	/**
	 * 清空结果集
	 *
	 * @return boolean
	 */
	final private function freeResult() {
		if ($this->resType == 'ARRAY') {
			$this->res = null;
		} elseif ($this->resType == 'RESOURCE') {
			@mysql_free_result($this->res);
		}
		return true;
	}
}
