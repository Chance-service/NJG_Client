<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 语言包类
 *
 * example:
 *
 * MooLanguage::setLocation('zh_cn');
 * MooLanguage::set('var', 'lang var');
 * $var = MooLanguage::get('demo.demokey');
 *
 */
final class MooLanguage implements MooLanguageInterface {
	/**
	 * 定义语言包所在文件夹
	 *
	 */
	private $langDir = '';

	/**
	 * 定义语言种类/目录
	 *
	 */
	private $location = 'zh_cn'; //默认是 zh_cn

	/**
	 * 文件名的后缀
	 *
	 */
	const CONF_SUFFIX = '.lang.php';

	/**
	 * 需要传入语言包的变量数据
	 *
	 * @var array
	 */
	private $dataReg = array();

	/**
	 *调用的key
	 *
	 */
	private $getKey = '';

	/**
	 * 构造函数
	 *
	 */
	public function __construct() {
		$this->langDir = MOOLANGUAGE_DIR;
		if (!MooFile::isExists($this->langDir)) {
			exit('ERROR: You must set lang dir first');
		}
	}

	/**
	 * 获取配置文件的内容
	 *
	 * @param string $keyName
	 * @return mix
	 */
	static public function get($keyName, $params = array()) {
		// 注册模式
		static $langReg = array();
		static $keyNameReg = array();

		$Language = self::_getInstance();

		$Language->getKey = $keyName;

		if (isset($keyNameReg[$keyName])) {
			return self::evalArrayLang(($keyNameReg[$keyName]), $params);
		}
		
		$langArr = explode('.', $keyName);

		// 第一个参数是文件名
		$fileName = array_shift($langArr);
		// 文件名必须是小写
		$fileName = strtolower($fileName);

		// 如果注册表中没有该配置，则从文件中读取
		if (!isset($langReg[$fileName])) {
			$langPath = $Language->langDir . '/'. $Language->location . '/' . $fileName . self::CONF_SUFFIX;
			$LANG = null;
			// 将配置文件包含进来
			require $langPath;

			// 将这个文件中的配置注册到内存中
			$langReg[$fileName] = $LANG;
		} // 否则,直接从注册表中返回
		else {
			$LANG = $langReg[$fileName];
		}

		// 读取值
		if (!$LANG) {
			return 'NO $LANG';
		}
		foreach ($langArr as $key) {
			if (!isset($LANG[$key]) || !is_array($LANG)) {
				return "$key undefined";
			}
			$LANG = $LANG[$key];
		}
		
		$keyNameReg[$keyName] = $LANG;
		
		$LANG = self::evalArrayLang($LANG, $params);
		
		return $LANG;
	}

	/**
	 * 对获取的语言包根据是否为数组分别解析其中的变量
	 *
	 * @param string $lang
	 * @return string
	 */
	static private function evalArrayLang($lang, $params) {
		
		if (is_array($lang)) {
			foreach ($lang as $key => $value) {
				$lang[$key] = is_array($value) ? self::evalArrayLang($value, $params) : self::replaceVar($value, $params);
			}
		} else {
			$lang = self::replaceVar($lang, $params);
		}
		return $lang;
	}
	
	
	static private function replaceVar($lang, $params){
		$Language = self::_getInstance();

		//note 返回是数组，需要检查get的值
		if(is_array($lang)) {
			return 'lang key '.$Language->getKey.' not a string';
		}
		
		// 替换变量
		$params = array_merge($Language->dataReg, $params);
		foreach ($params as $key => $value) {
			$lang = str_replace('{$' . $key . '}', $value, $lang);
			$lang = str_replace(' $' . $key . ' ', $value, $lang);
		}
		
		return $lang;
	}
	
	/**
	 * 解析语言包里面的变量
	 *
	 * @param string $lang
	 * @return string
	 */
	private function evalLang($lang, $params) {

		$Language = self::_getInstance();

		//note 返回是数组，需要检查get的值
		if(is_array($lang)) {
			return 'lang key '.$Language->getKey.' not a string';
		}
		
		// 替换变量
		$params = array_merge($Language->dataReg, $params);
		foreach ($params as $key => $value) {
			$lang = str_replace('{$' . $key . '}', $value, $lang);
			$lang = str_replace(' $' . $key . ' ', $value, $lang);
		}
		
		return $lang;
	}

	/**
	 * 设置数据
	 *
	 * @param string $k
	 * @param value $v
	 */
	static public function set($k, $v = '') {
		$Language = self::_getInstance();
		$Language->dataReg[$k] = $v;
	}

	/**
	 * 定义语言种类/目录
	 *
	 * @param string $local
	 */
	static public function setLocation($location) {
		$Language = self::_getInstance();
		$Language->location = $location;
	}

	/**
	 * 单件
	 *
	 * @return object
	 */
	static private function _getInstance() {
		if (isset($this) && is_object($this) && $this instanceof MooLanguage) {
			return $this;
		}
		static $Language = null;
		if (!$Language) {
			$Language = new MooLanguage();
		}
		return $Language;
	}
}