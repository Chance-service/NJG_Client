<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc
 * 本文件是操作某一个表的类。
 * 所有继承本类的子类必须先调用_setAdapter()方法设置适配器，之后才可使用。
 * 本类中的适配器指定必须使用library/db.lib.php。
 * 
 * 本类不能直接实例化调用，必须被继承。
 *
 */
class MooDBTable implements MooDBTableInterface {

	private $error = '';

	/**
	 * DB适配器,本类中的所有数据库操作都由该适配器完成
	 * 详情参考方法：_callAdapterFunc()、_setAdapter()
	 *
	 * @var object
	 */
	private $db;

	/**
	 * dao对象的注册器
	 *
	 * @var array
	 */
	private $daoObjReg = array();

	/**
	 * 用于存储将要入库的数据
	 *
	 * @var object
	 */
	protected $data = null;
	protected $dataDao = null;

	/**
	 * 表名。本属性应该被继承并将其设置为某数据表的表名
	 *
	 * @var string
	 */
	public $tableName = '';

	/**
	 * 本表的主键。本属性应该被继承并将其设置为某数据表的主键名(本类不支持双字段或多字段主键)
	 *
	 * @var string
	 */
	public $primaryKey = '';

	/**
	 * dao的目录路径
	 *
	 * @var string
	 */
	public $daoDir;

	/**
	 * dao的名称
	 *
	 * @var string
	 */
	public $daoName;

	/**
	 * 构造函数，本构造函数允许重载
	 *
	 */
	public function __construct() {
	}

	public function clearDebugSql() {
		$this->db->clearDebugSql();
	}

	/**
	 * 获得最近一次插入的id
	 *
	 * @return int
	 */
	final public function getInsertId() {
		return $this->_callAdapterFunc('getInsertId', array());
	}

	/**
	 * 获取当前记录的错误
	 *
	 * @return array
	 */
	final public function getError() {
		return $this->error;
	}

	/**
	 * 设置错误消息
	 *
	 * @param string $error
	 */
	final protected function setError($error) {
		$this->error = $error;
	}

	/**
	 * 获取所有数据
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @return array
	 */
	public function getAll($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		return $this->_callAdapterFunc('getAll', array($sql, $param, $exit, $cache, $cacheDir));
	}

	/**
	 * 获取一行数据
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @return array
	 */
	public function getRow($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		return $this->_callAdapterFunc('getRow', array($sql, $param, $exit, $cache, $cacheDir));
	}

	/**
	 * 获取一个数据
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @return array
	 */
	public function getOne($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		return $this->_callAdapterFunc('getOne', array($sql, $param, $exit, $cache, $cacheDir));
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
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		MooDBPagin::setRows($rows);
		MooDBPagin::setLinks($links);
		return MooDBPagin::getPage($this->db, $sql, $param, $exit, $cache, $totalCache);
	}

	/**
	 * 获取一列数据
	 *
	 * @param string $sql
	 * @param array $param
	 * @param boolean $exit
	 * @param int $cache
	 * @return array
	 */
	public function getCol($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		return $this->_callAdapterFunc('getCol', array($sql, $param, $exit, $cache, $cacheDir));
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
		$sql = str_ireplace('@TABLE', "`{$this->tableName}`", $sql);
		return $this->_callAdapterFunc('query', array($sql, $param, $exit, $cache, $cacheDir));
	}

	/**
	 * 设置本表各个字段的数据,入库用
	 *
	 * @param string	$key	字段名
	 * @param mix		$value	字段值
	 */
	public function setData($key, $value) {
		$this->data->{$key}[] = array('value' => $value, 'type' => 'setData');
	}

	/**
	 * 设置本表各个字段的数据,入库用
	 *
	 * @param string	$key	字段名
	 * @param mix		$value	字段值
	 */
	public function setExpr($key, $value) {
		$this->data->{$key}[] = array('value' => $value, 'type' => 'setExpr');
	}

	/**
	 * 设置本表各个字段的数据,入库用
	 *
	 * @param string	$key	字段名
	 * @param mix		$value	字段值
	 */
	public function setDaoData($key, $value) {
		$this->dataDao->{$key}[] = array('value' => $value, 'type' => 'setData');
	}

	/**
	 * 设置本表各个字段的数据,入库用
	 *
	 * @param string	$key	字段名
	 * @param mix		$value	字段值
	 */
	public function setDaoExpr($key, $value) {
		$this->dataDao->{$key}[] = array('value' => $value, 'type' => 'setExpr');
	}

	/**
	 * 向表中插入一条新数据
	 * 本方法允许重载，但重载时应该注意不要修改本方法中已有的代码，建议在重载时调用用parent::insert()
	 *
	 * @param boolean $exit	当发生错误时是否中断程序
	 * @return boolean
	 */
	public function insert($exit = true) {
		foreach ((array)$this->data as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setExpr') {
					$this->_callAdapterFunc('setExpr', array($k, $v['value']));
				} else {
					$this->_callAdapterFunc('setData', array($k, $v['value']));
				}
			}
		}

		$rs = (boolean)$this->_callAdapterFunc('insert', array($this->tableName, $exit));
		$this->data = null;
		$this->dataX = null;
		return $rs;
	}

	/**
	 * 根据主键更新表中的一条数据
	 * 本方法允许重载，但重载是应该注意不要修改本方法中已有的代码，建议在重载时调用用parent::update()
	 *
	 * @param mix		$id		主键值
	 * @param string	$pk		主键名 注意：如果你不确定你设定的字段确实能够取代默认主键，请不要设置这个值
	 * @param boolean	$exit	当发生错误时是否中断程序
	 * @return boolean
	 */
	public function update($id, $pk = '', $exit = true) {
		// 如果没有设置要修改的字段，则直接返回true
		if (!$this->data && !$this->dataDao) {
			return true;
		}

		foreach ((array)$this->data as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setExpr') {
					$this->_callAdapterFunc('setExpr', array($k, $v['value']));
				} else {
					$this->_callAdapterFunc('setData', array($k, $v['value']));
				}
			}
		}

		foreach ((array)$this->dataDao as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setExpr') {
					$this->_callAdapterFunc('setExpr', array($k, $v['value']));
				} else {
					$this->_callAdapterFunc('setData', array($k, $v['value']));
				}
			}
		}

		// 如果没有指定主键，则使用实力化时设置的默认主键
		$pk = $pk ? $pk : $this->primaryKey;

		$rs = (boolean)$this->_callAdapterFunc('update', array($this->tableName, $pk, $id, $exit));

		if ($rs && $this->data) {
			// 更新成功后，判断此次更新是否影响到对应的daoObj数据，如果有影响，则需要同步更新。
			$mooDaoRegister = MooDaoRegister::factory();
			$daoObjReg = $mooDaoRegister->getReg(get_class($this), $id, $pk);
			foreach ($daoObjReg as $dao) {
				$dao->_up($this->data);
			}
		}

		// 清除更新的数据
		$this->data = null;
		$this->dataDao = null;

		return $rs;
	}

	/**
	 * 根据主键删除表中的一条数据
	 * 本方法允许重载，但重载时应该注意不要修改本方法中已有的代码，建议在重载时调用用parent::delete()
	 *
	 * @param mix		$id		主键值
	 * @param string	$pk		主键名 注意：如果你不确定你设定的字段确实能够取代默认主键，请不要设置这个值
	 * @param boolean	$exit	当发生错误时是否中断程序
	 */
	public function delete($id, $pk = '', $exit = true) {
		// 如果没有指定主键，则使用实力化时设置的默认主键
		$pk = $pk ? $pk : $this->primaryKey;

		// 如果注册器存在，则删除注册器中的数据对象
		$mooDaoRegister = MooDaoRegister::factory();
		$daoObjReg = $mooDaoRegister->getReg(get_class($this), $id, $pk);
		if ($daoObjReg && count($daoObjReg) == 1) {
			$mooDaoRegister->del(get_class($this));
		}

		return (boolean)$this->_callAdapterFunc('delete', array($this->tableName, $pk, $id, $exit));
	}

	/**
	 * 返回一个数据对象，本方法不允许重载
	 *
	 * @param int $id
	 * @param string $pk
	 * @param boolean $useReg
	 * @param boolean $exit
	 * @return object|false
	 */
	public function load($id, $pk = '', $useReg = true, $exit = true) {
		// 如果没有指定主键，则使用实力化时设置的默认主键
		$pk = $pk ? $pk : $this->primaryKey;

		// 判断是否需要使用注册器
		if ($useReg) {
			// 如果注册器存在，则直接返回注册器中的数据对象
			$mooDaoRegister = MooDaoRegister::factory();
			$daoObjReg = $mooDaoRegister->getReg(get_class($this), $id, $pk);
			if ($daoObjReg && count($daoObjReg) == 1) {
				return $daoObjReg[0];
			}
		}
		if (defined('DAOOBJ_CACHE') && DAOOBJ_CACHE) {
			$daoObj = MooCache::get('daoObj/' . $this->tableName . '/' . substr($id, 0, 3) . '/' . substr($id, 0, 6) . '/' . $id. '_' . $pk);
			if ($daoObj && is_object($daoObj) && $daoObj instanceof MooDaoObj) {
				return clone $daoObj;
			}
		}
		// 开始查询数据
		if (!is_array($id)) {
			if (!$pk) {
				MooLog::error('ERROR: You must set primaryKey first.');
				return false;
			}
			$sql = "SELECT * FROM  `{$this->tableName}` WHERE `{$pk}` = :primaryKey";
			$rs = $this->_callAdapterFunc('getAll', array($sql, array('primaryKey' => $id), $exit));
		} else {
			$keyArr = array_keys($id);
			$where = array();
			foreach ($keyArr as $k) {
				$where[] = "{$k} = :{$k}";
			}
			$sql = "SELECT * FROM  `{$this->tableName}` WHERE " . implode(' AND ', $where);
			$rs = $this->_callAdapterFunc('getAll', array($sql, $id, $exit));
		}

		// 如果查询返回false，或者查询不到数据，则退出
		if ($rs === false) {
			return false;
		} elseif (count($rs) == 0) {
			return null;
		} elseif (count($rs) > 1) {
			MooLog::error('ERROR: The result not unique');
		}

		// 如果一切正常，则返回DaoObj对象
		$daoObj = new MooDaoObj(clone $this);
		// 将数据放入daoObj对象
		$daoObj->_upData($rs[0]);

		// 如果需要注册，则执行注册
		if ($useReg) {
			$mooDaoRegister = MooDaoRegister::factory();
			$mooDaoRegister->reg(get_class($this), $daoObj);
		}
		return $daoObj;
	}

	/**
	 * 设置本类中用到的DB的数据库操作适配器，本类中的所有数据库操作都由该适配器完成
	 * 所有继承本类的子类必须先调用此方法设置适配器
	 * 本方法允许被继承，但不允许被重载
	 *
	 * @param object $db DB适配器
	 */
	final protected function _setAdapter($db) {
		if (!($db instanceof MooDB)) {
			exit('ERROR: Adapter does not extend MooDB');
		}

		$this->db = $db;
	}
	
	final function setAdapter($db) {
		$this->_setAdapter($db);
	}

	/**
	 * 调用适配器对象中方法的统一接口
	 * 本方法不允许被继承，不允许被重载
	 *
	 * @param string	$method	适配器的方法
	 * @param array		$param	适配器的参数
	 * @return mix
	 */
	final private function _callAdapterFunc($method, $param) {
		$rs = call_user_func_array(array(&$this->db, $method), $param);
		if ($rs === false) {
			$msg = $this->db->getError();
			MooLog::error($msg);
			$this->setError($msg);
			return false;
		} else {
			$this->error && $this->setError('');
			return $rs;
		}
	}

	/**
	 * 自动调用未定义函数
	 *
	 * @param string $method
	 * @param mix $param
	 * @return mix
	 */
	public function __call($method, $param) {
		static $methodReg = array();

		if (!$funcClassName = $methodReg[$method]) {
			// 由Dao对象load一个Dao之后，就会自动设置$this->daoDir与$this->daoName
			// 对象路由
			$daoPath = self::getFuncPath($this->daoName, $method);
			if (!$daoPath) {
				exit("ERROR: The method of '{$method}' in '{$this->daoName}_Dao' is undefine");
			}

			require_once $daoPath . '_' . $method . '.php';

			// 创建对象
			$funcClassName = 'Dao_' . basename($daoPath) . '_' . $method;
			$methodReg[$method] = $funcClassName;
		}
		$obj = new $funcClassName($this);

		// 调用对象的方法
		return call_user_func_array(array(&$obj, $method), $param);
	}

	/**
	 * 读取对象方法所在路径
	 *
	 * @param string $objDir
	 * @param string $method
	 * @return string
	 */
	private function getFuncPath($daoName, $method) {
		// 加载对象所在目录
		$daoDir = str_replace('_', '/', $daoName);
		if (!$daoDir) {
			return false;
		}

		$daoPath = $this->daoDir . '/' . $daoDir . '/' . $daoName;

		// 如果当前对象不存在该方法，则搜索父对象
		if (!MooFile::isExists($daoPath . '_' . $method . '.php')) {
			$lebel = strrpos($daoName, '_');
			$daoName = $lebel ? substr($daoName, 0, $lebel) : '';
			return $this->getFuncPath($daoName, $method);
		} else {
			return $daoPath;
		}
	}
}

/**
 * 数据对象
 *
 */
class MooDaoObj implements MooDaoObjInterface {
	private $fields		= array();
	private $priData	= array(); // 原始数据
	private $upData		= array(); // 待更新的数据
	private $dao;
	private $error = '';
	private $Pattern = array();

	/**
	 * 构造函数
	 *
	 * @param object $dao
	 */
	function __construct($dao) {
		$this->dao = $dao;
	}

	/**
	 * 析构函数
	 *
	 */
	function __destruct() {
		if (!$this->update()) {
			MooLog::error('mooDaoObj __destruct error');
			if (defined('DAOOBJ_CACHE') && DAOOBJ_CACHE) {
				$id = $this->fields[$this->dao->primaryKey];
				$pk = $this->dao->primaryKey;
				$tableName = $this->dao->tableName;
				$time = DAOOBJ_CACHE_TIME;
				if ($time < 3600) {
					$time = 3600;
				}
				$obj = MooCache::get('daoObj/' . $tableName . '/' . substr($id, 0, 3) . '/' . substr($id, 0, 6) . '/' . $id. '_' . $pk, $this, $time);
				if ($obj != $this) {
					MooCache::set('daoObj/' . $tableName . '/' . substr($id, 0, 3) . '/' . substr($id, 0, 6) . '/' . $id. '_' . $pk, $this, $time);
				}
			}
		}
	}

	function _up($data) {
		$this->upData = array();

		if (!$data) {
			return;
		}

		$setData = $setExpr = array();
		foreach ($data as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setData') {
					$this->fields[$k] = $v['value'];
				} else {
					
					foreach ($this->Pattern as $pattern) {
						// 替换不带`的字段
						$v['value'] = str_replace($pattern[0], $pattern[1], $v['value'], $count);
						// 如果替换成功则中断
						if ($count) {
							break;
						}
						// 替换带`的字段
						$v['value'] = str_replace("`{$pattern[0]}`", $pattern[1], $v['value'], $count);
						// 如果替换成功则中断
						if ($count) {
							break;
						}
					}
		
					$eval = "\$this->fields['$k'] = {$v['value']};";
					$rs = @eval($eval);
					if ($rs === false) {
						MooLog::error($eval);
					}
				}
			}
		}
	}
	
	/**
	 * 更新数据，这个接口逻辑上仅向MooDBTable类开放
	 *
	 * @param array $data
	 */
	public function _upData($data) {
		$this->upData = array();
		$this->priData = array();
		if (!$data) {
			return;
		}
		
		// 字段越长的排在越前面，避免后期做替换的时候，短的替换掉了长的。
		$dataLen = array();
		foreach ($data as $k => $v) {
			$dataLen[strlen($k)][$k] = $v;
		}
		krsort($dataLen);
		
		foreach ($dataLen as $row) {
			foreach ($row as $k => $v) {
				$this->fields[$k] = $v;
				$this->priData[$k] = $v;
			}
		}

		if (!$this->Pattern) {
			$this->Pattern = array();

			foreach ($this->fields as $key => $value) {
				$this->Pattern[] = array($key, "\$this->fields['" . $key . "']");
			}
		}
	}

	/**
	 * 读取数据
	 *
	 * @param string $k
	 * @return string
	 */
	public function __get($k) {
		if (!key_exists($k, $this->fields)) {
			exit('ERROR: The property of ' . $k . ' not exsits');
		}
		return $this->fields[$k];
	}

	/**
	 * 修改数据
	 *
	 * @param mix $k
	 * @param mix $v
	 */
	public function __set($k, $v) {
		exit('You should not set property directly');
	}

	/**
	 * 修改数据
	 *
	 * @param mix $k
	 * @param mix $v
	 */
	public function set($k, $v) {
		$this->monitorSet($k, $v);
		$this->fields[$k] = $v;
		$this->upData[$k][] = array('value' => $v, 'type' => 'set');
	}
	
	private function monitorSet($k, $v) {
		// 如果该表关闭了监控，则直接返回
		if ($this->dao->monitorClose) {
			return false;
		}
		
		// 如果设置了关闭对指定字段的监控，则直接返回
		if (in_array($k, (array)$this->dao->fieldMonitorClose)) {
			return false;
		}
		
		if (!is_numeric($v)) {
			return false;
		}
		
		// 判断是否有定制的监测额度
		if ($this->dao->fieldMonitorSet[$k] && $v - $this->priData[$k] > $this->dao->fieldMonitorSet[$k]) {
			MooLog::write("Old:{$this->priData[$k]} -- New:{$v}", 'setLog/' . $k);
			return true;
		}
		
		if ($v < 100 || strpos($k, 'dateline') || strpos($k, 'time')) {
			return false;
		}
		
		if ($this->priData[$k] > 5000) {
			// 如果原始数值大于5000，差值大于300则认为需要监控。
			$v - $this->priData[$k] > 300 ? MooLog::write("Old:{$this->priData[$k]} -- New:{$v}", 'setLog/' . $k) : 0;
		} elseif ($this->priData[$k] > 1000) {
			// 如果原始数值大于1000，差值大于200则认为需要监控。
			$v - $this->priData[$k] > 200 ? MooLog::write("Old:{$this->priData[$k]} -- New:{$v}", 'setLog/' . $k) : 0;
		} elseif ($this->priData[$k] > 100) {
			// 如果原始数值大于100，差值大于100则认为需要监控。
			$v - $this->priData[$k] > 100 ? MooLog::write("Old:{$this->priData[$k]} -- New:{$v}", 'setLog/' . $k) : 0;
		} elseif ($v > 150) {
			// 如果原始数值小于100，则新的数值大于150则认为需要监控。
			MooLog::write("Old:{$this->priData[$k]} -- New:{$v}", 'setLog/' . $k);
		}
		
		return true;
	}

	/**
	 * 修改数据
	 *
	 * @param mix $k
	 * @param mix $v
	 */
	public function setx($k, $v) {
		$this->upData[$k][] = array('value' => $v, 'type' => 'setx');
		foreach ($this->Pattern as $pattern) {
			// 替换不带`的字段
			$v = str_replace($pattern[0], $pattern[1], $v, $count);
			// 如果替换成功则中断
			if ($count) {
				break;
			}
			// 替换带`的字段
			$v = str_replace("`{$pattern[0]}`", $pattern[1], $v, $count);
			// 如果替换成功则中断
			if ($count) {
				break;
			}
		}

		$eval = "\$this->fields['$k'] = $v;";
		//var_dump($eval);
		$rs = @eval($eval);
		if ($rs === false) {
			MooLog::error($eval);
		}
	}

	/**
	 * 读取数据
	 *
	 * @return array
	 */
	public function getData() {
		return $this->fields;
	}

	/**
	 * 设置提示信息
	 *
	 * @param string $msg
	 */
	private function setError($error) {
		$this->error[] = $error;
	}

	/**
	 * 获取提示信息
	 *
	 * @return array
	 */
	public function getError() {
		return $this->error;
	}

	/**
	 * 执行更新操作
	 *
	 * @return boolean
	 */
	public function update($exit = true) {
		if (!$this->upData) {
			return true;
		}

		if (!$this->dao->primaryKey) {
			$this->setError('No primaryKey to use');
			MooLog::error('No primaryKey to use');
			return false;
		}

		foreach ($this->upData as $k => $row) {
			foreach ($row as $v) {
				if ($v['type'] == 'setx') {
					$this->dao->setDaoExpr($k, $v['value']);
				} else {
					$this->dao->setDaoData($k, $v['value']);
				}
			}
		}

		$rs = $this->dao->update($this->fields[$this->dao->primaryKey], null, $exit);
		if (!$rs) {
			$this->setError($this->dao->getError());
		}
		$this->upData = array();
		return $rs;
	}

	/**
	 * 执行删除操作
	 *
	 * @return boolean
	 */
	public function delete($exit = true) {
		if (!$this->dao->primaryKey) {
			$this->setError('No primaryKey to use');
			MooLog::error('No primaryKey to use');
			return false;
		}

		$rs = $this->dao->delete($this->fields[$this->dao->primaryKey], null, $exit);
		if (!$rs) {
			$this->setError($this->dao->getError());
		}
		return $rs;
	}
}

class MooDao {
	/**
	 * 自动加载Dao
	 *
	 * @param string $daoName
	 * @param string $daoDir
	 * @param boolean $exit
	 * @return object
	 */
	static function get($daoName, $daoDir = '', $exit = false) {
		static $daoReg = array();
		if (isset($daoReg[$daoName])) {
			return $daoReg[$daoName];
		}

		$daoDir = $daoDir ? $daoDir : MOODAO_DAO_DIR;
		if (!MooFile::isExists($daoDir)) {
			exit('ERROR: You must define dao dir first.');
		}

		// 对象路由
		$daoArr		= explode('_', $daoName);
		$daoPath	= '';
		foreach ($daoArr as $value) {
			$daoPath .= '/' . $value;
		}

		// 判断对象是否存在
		$daoPath = $daoPath. '/' . $daoName . '.dao.php';
		if (!MooFile::isExists($daoDir . $daoPath)) {
			if ($exit) {
				exit('ERROR: The dao path of "' . $daoPath . '" is not found');
			} else {
				return false;
			}
		}
		//　加载对象
		require_once $daoDir . $daoPath;

		$daoClassName = 'Dao_' . $daoName;
		$dao = new $daoClassName();
		$dao->daoName = $daoName;
		$dao->daoDir = $daoDir;
		$daoReg[$daoName] = $dao;
		return $dao;
	}
}

function now() {
	return date('Y-m-d H:i:s');
}

function concat() {
	$param = func_get_args();
	if (!$param) {
		return '';
	}
	$str = '';
	foreach ($param as $v) {
		$str .= $v;
	}
	return $str;
}

class MooDaoRegister {
	public $reg = array();

	static function factory() {
		static $mooDaoRegister = null;
		if (!$mooDaoRegister) {
			$mooDaoRegister = new MooDaoRegister();
		}
		return $mooDaoRegister;
	}

	function reg($className, $dao) {
		$this->reg[$className][] = $dao;
	}

	function del($className) {
		$this->reg[$className] = null;
		unset($this->reg[$className]);
	}

	/**
	 * 
	 * 根据传入的id和pk，来找到已经注册的dao对象
	 *
	 * @param string $className
	 * @param mix $id
	 * @param string $pk
	 * @return string
	 */
	function getReg($className, $id, $pk) {
		if (!$this->reg[$className]) {
			return array();
		}

		$regDao = array();
		foreach ($this->reg[$className] as $k => $dao) {
			// 如果使用单一的键值对作为查询条件，则判断该键值对是否存在于已经注册的某个dao对象中。如果存在则返回该对象
			if (!is_array($id)) {
				if ($dao->$pk == $id) {
					$regDao[] = $dao;
				}
			}
			// 如果使用多组键值对作为查询条件，则判断多有的键值对是否存在于已经注册的某个dao对象中。如果存在则返回该对象
			else {
				$ok = true;
				foreach ($id as $idK => $idV) {
					if ($dao->$idK != $idV) {
						$ok = false;
						break;
					}
				}
				if ($ok == true) {
					$regDao[] = $dao;
				}
			}
		}
		return $regDao;
	}

	function destruct() {
		if (!$this->reg) {
			return ;
		}
		foreach ($this->reg as $k => $row) {
			foreach ($row as $obj) {
				$obj->__destruct();
			}
		}
		$this->reg = null;
		unset($this->reg);
	}
}
