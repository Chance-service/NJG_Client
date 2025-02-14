<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

abstract class MooObject {
	/**
	 * 对象的存放目录
	 *
	 * @var string
	 */
	public $objDir;

	/**
	 * 自动调用未定义函数
	 *
	 * @param string $method
	 * @param mix $param
	 * @return mix
	 */
	public function __call($method, $param) {
		static $methodReg = array();

		// 读取当前对象名称
		$className = get_class($this);
		$regLabel = $className . '_' . $method;

		// 解决重复调用的问题。如果重复调用同一个方法，则不需用重新路由
		isset($methodReg[$regLabel]) && $funcClassName = $methodReg[$regLabel];
		if (!isset($funcClassName) || !$funcClassName) {

			// 自动寻路，查找需要调用的函数
			$funcPath = self::_getFuncPath($className, $method);
			if (!$funcPath) {
				$this->error("The method file of '{$method}' in '{$className}' is not exists");
			}

			// 加载函数对象的路径
			require_once $this->objDir . '/' . $funcPath . '.php';

			// 将函数所在的路径转换为函数名
			$pathArr = explode('/', $funcPath);
			array_pop($pathArr);
			$funcClassName = join('_', $pathArr) . '_' . $method;

			$methodReg[$regLabel] = $funcClassName;
		}

		// 创建对象
		if (!class_exists($funcClassName)) {
			$this->error("The method of '{$funcClassName}' in '{$className}' is undefine");
		}
		$obj = new $funcClassName($this);

		$obj->OBJ = $this;

		// 调用对象的方法
		$rs = call_user_func_array(array(&$obj, $method), $param);
		unset($obj);
		return $rs;
	}

	public function checkMethodExists($method) {
		static $methodReg = array();

		// 读取当前对象名称
		$className = get_class($this);
		$regLabel = $className . '_' . $method;
		if (method_exists($this, $method)) {
			return true;
		}

		if (isset($methodReg[$regLabel])) {
			return true;
		}

		// 自动寻路，查找需要调用的函数
		if (self::_getFuncPath($className, $method)) {
			$methodReg[$regLabel] = true;
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 读取对象方法所在路径
	 *
	 * @param string $objDir
	 * @param string $method
	 * @return string
	 */
	private function _getFuncPath($objName, $method) {
		if (!$objName) {
			return false;
		}
		// 加载对象所在目录
		$objArr	= explode('_', $objName);
		$objPath = join('/', $objArr) . '/' . array_pop($objArr) . '_' . $method;

		// 如果当前对象不存在该方法，则搜索父对象
		if (!MooFile::isExists($this->objDir . '/' . $objPath . '.php')) {
			$lebel = strrpos($objName, '_');
			$objName = $lebel ? substr($objName, 0, $lebel) : '';
			return $this->_getFuncPath($objName, $method);
		} else {
			return $objPath;
		}
	}

	/**
	 * 错误处理函数
	 *
	 * @param string $msg
	 */
	protected function error($msg) {
		$debug = debug_backtrace();
		echo $msg;
		echo "<br>\nfile: {$debug[2]['file']}";
		echo "<br>\nline: {$debug[2]['line']}";
		exit;
	}

	/**
	 * 添加(一条)消息记录
	 * example:
	 * $this->setMsg('用户名格式错误');
	 * $this->setMsg(array('用户名格式错误', '密码格式错误'));
	 *
	 * @param mix $error
	 */
	public function setMsg($message) {
		MooError::set($message);
	}

	/**
	 * 获取消息记录
	 *
	 * @param mix $error
	 */
	public function getMsg() {
		return MooError::get();
	}
}

class MooObj {
	private $message;
	
	/**
	 * 对象创建器
	 *
	 * @param string $obj
	 * @param string $reg
	 * @return object
	 */
	static public function get($objName, $objDir = '', $reg = true, $exit = true) {
		static $objReg = array();

		// 注册模式，对于对象而言，每个对象本身可以是单键的。因此可以考虑使用注册模式来去掉没有必要的重复实力话。
		if ($reg && isset($objReg[$objName])) {
			return $objReg[$objName];
		}

		// 如果没有手动指定object所在目录，则加载配置文件中的object所在目录
		$objDir = $objDir ? $objDir : MOOOBJ_OBJ_DIR;
		if (!MooFile::isExists($objDir)) {
			if ($exit) {
				self::error('ERROR: You must define obj dir first.');
			} else {
				return false;
			}
		}

		// 对象路由
		$objArr		= explode('_', $objName);
		foreach ($objArr as $value) {
			$thePath .= '/' . $value;

			// 判断对象是否存在
			$objPath = $objDir . $thePath . '/' . $value . '.obj.php';
			if (!MooFile::isExists($objPath)) {
				if ($exit) {
					self::error('ERROR: The obj path of "' . $thePath . '" is not exists');
				} else {
					return false;
				}
			}
			//　加载对象
			require_once $objPath;
		}

		// 创建对象
		if (!class_exists($objName)) {
			return false;
		}
		$obj = new $objName();

		// 设置对象的存放目录
		$obj->objDir = $objDir;

		// 判断是否注册该对象
		if ($reg) {
			$objReg[$objName] = $obj;
		}
		return $obj;
	}
	
	private function error($msg) {
		$debug = debug_backtrace();
		echo $msg;
		echo "<br>\nfile: {$debug[1]['file']}";
		echo "<br>\nline: {$debug[1]['line']}";
		exit;
	}
}