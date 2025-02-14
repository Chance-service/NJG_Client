<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 配置读取操作类
 *
 * example:
 *
 * $dbConf = Config::get('database.yeswan.host');
 * print_r($dbConf);
 *
 */
class MooConfig implements MooConfigInterface {
	/**
	 * 定义配置所在文件夹
	 *
	 */
	private $confDir = '';

	/**
	 * 配置文件名的后缀
	 *
	 */
	const CONF_SUFFIX = '.conf.php';

	/**
	 * 构造函数
	 *
	 */
	public function __construct() {
		$this->confDir = MOOCONFIG_CONF_DIR;
		if (!MooFile::isExists($this->confDir)) {
			exit('ERROR: You must set conf dir first');
		}
	}
	
	static public function setConfDir($confDir) {
		$Config = self::_getInstance();
		$Config->confDir = $confDir;
	}

	/**
	 * 获取配置文件的内容
	 *
	 * @param string $keyName
	 * @return mix
	 */
	static public function get($keyName) {
		// 注册模式
		static $confReg = array();
		static $keyNameReg = array();
		
		if (isset($keyNameReg[$keyName])) {
			return $keyNameReg[$keyName];
		}
		
		$Config = self::_getInstance();

		$confArr = explode('.', $keyName);

		// 第一个参数是文件名
		$fileName = array_shift($confArr);
		// 文件名必须是小写
		$fileName = strtolower($fileName);

		// 如果注册表中没有该配置，则从文件中读取
		if (!isset($confReg[$fileName])) {
			$confPath = $Config->confDir . '/' . $fileName . self::CONF_SUFFIX;

			// 在指定目录没有找到相应文件后，则往上一级目录找
			if (!MooFile::isExists($confPath)) {
				$confPath = dirname($Config->confDir) . '/' . $fileName . self::CONF_SUFFIX;
				if (!MooFile::isExists($confPath)) {
					$confPath = dirname(dirname($Config->confDir)) . '/' . $fileName . self::CONF_SUFFIX;
				}
			}

			$CONF = null;
			// 将配置文件包含进来
			require $confPath;

			// 将这个文件中的配置注册到内存中
			$confReg[$fileName] = $CONF;
		} // 否则,直接从注册表中返回
		else {
			$CONF = $confReg[$fileName];
		}

		// 读取值
		if (!$CONF) {
			return null;
		}
		foreach ($confArr as $key) {
			if (!isset($CONF[$key])) {
				MooLog::error('The config of ' . $keyName . ' is undefine');
			}
			$CONF = $CONF[$key];
		}
		
		$keyNameReg[$keyName] = $CONF;
		return $CONF;
	}

	/**
	 * 设置配置目录
	 *
	 * @param string $configDir
	 * example:
	 * MooConfig::set(MOOCONFIG_CONF_DIR.'/xiaonei');
	 */
	static public function set($configDir) {
		$Config = self::_getInstance();
		$Config->confDir = $configDir;
	}

	/**
	 * 单件
	 *
	 * @return object
	 */
	static private function _getInstance() {
		if (isset($this) && is_object($this) && $this instanceof MooConfig) {
			return $this;
		}
		static $Config = null;
		if (!$Config) {
			$Config = new MooConfig();
		}
		return $Config;
	}
}