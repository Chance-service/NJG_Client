<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

abstract class MooModule {
	/**
	 * 对象的存放目录
	 *
	 * @var string
	 */
	public $modDir;

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
		$className = $this->modName;
		$regLabel = $className . '_' . $method;

		// 解决重复调用的问题。如果重复调用同一个方法，则不需用重新路由
		isset($methodReg[$regLabel]) && $funcClassName = $methodReg[$regLabel];
		if (!isset($funcClassName) || !$funcClassName) {

			// 自动寻路，查找需要调用的函数
			$funcPath = $this->_getFuncPath($className, $method);
			if (!$funcPath) {
				$this->error("The method file of '{$method}' in '{$className}' is not exists");
			}
			
			// 加载函数对象的路径
			require_once $this->modDir . '/' . $funcPath . '.php';
			
			// 将函数所在的路径转换为函数名
			$pathArr = explode('/', $funcPath);
			array_pop($pathArr);
			$funcClassName = 'Mod_' . join('_', $pathArr) . '_' . $method;

			$methodReg[$regLabel] = $funcClassName;
		}
		
		// 创建对象
		if (!class_exists($funcClassName)) {
			$this->error("The method of '{$funcClassName}' in '{$className}' is undefine");
		}
		$mod = new $funcClassName($this);
		$mod->MOD = $this;

		// 调用对象的方法
		$rs = call_user_func_array(array(&$mod, $method), $param);
		unset($mod);
		return $rs;
	}

	/**
	 * 读取对象方法所在路径
	 *
	 * @param string $modDir
	 * @param string $method
	 * @return string
	 */
	private function _getFuncPath($modName, $method) {
		if (!$modName) {
			return false;
		}
		// 加载对象所在目录
		$modArr	= explode('_', $modName);
		$modPath = join('/', $modArr) . '/' . array_pop($modArr) . '_' . $method;
		
		// 如果当前对象不存在该方法，则搜索父对象
		if (!MooFile::isExists($this->modDir . '/' . $modPath . '.php')) {
			$lebel = strrpos($modName, '_');
			$modName = $lebel ? substr($modName, 0, $lebel) : '';
			return $this->_getFuncPath($modName, $method);
		} else {
			return $modPath;
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

class MooMod {
	private $message;
	/**
	 * 对象创建器
	 *
	 * @param string $mod
	 * @param string $reg
	 * @return module
	 */
	static public function get($modName, $modDir = '', $reg = true, $exit = true) {
		static $modReg = array();

		// 注册模式，对于对象而言，每个对象本身可以是单键的。因此可以考虑使用注册模式来去掉没有必要的重复实力话。
		if ($reg && isset($modReg[$modName])) {
			return $modReg[$modName];
		}

		// 如果没有手动指定module所在目录，则加载配置文件中的module所在目录
		$modDir = $modDir ? $modDir : MOOMOD_MOD_DIR;
		if (!MooFile::isExists($modDir)) {
			if ($exit) {
				exit('ERROR: You must define mod dir first.');
			} else {
				return false;
			}
		}

		// 对象路由
		$modArr		= explode('_', $modName);
		foreach ($modArr as $value) {
			$thePath .= '/' . $value;

			// 判断对象是否存在
			$modPath = $modDir . $thePath . '/' . $value . '.mod.php';
			if (!MooFile::isExists($modPath)) {
				if ($exit) {
					exit('ERROR: The mod path of "' . $thePath . '" is not exists');
				} else {
					return false;
				}
			}
			//　加载对象
			require_once $modPath;
		}

		$modClassName =  'Mod_' . $modName;
		// 创建对象
		if (!class_exists($modClassName)) {
			return false;
		}
		$mod = new $modClassName();

		// 设置对象的存放目录
		$mod->modDir = $modDir;
		$mod->modName = $modName;

		// 判断是否注册该对象
		if ($reg) {
			$modReg[$modName] = $mod;
		}
		return $mod;
	}
}