<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * 日志类
 * 
 * 
 * 使用方法： 
 * MooLog::setNameFormat('Ymd-H');// 按小时切分日志
 * MooLog::write($msg, $flag);
 * MooLog::show($msg);
 * MooLog::tee($msg, $flag);
 * 
 */
final class MooLog implements MooLogInterface {
	private $logDir = '';
	private $filterDir = '';

	public function __construct() {
		if (!defined('MOOLOG_LOG_DIR')) {
			exit('ERROR: You must define log dir first.');
		}
		$this->logDir		= MOOLOG_LOG_DIR;
		$this->filterDir	= MOOLOG_FILTER_DIR;

	}
	// 日志文件名日期格式
	private $logNameFormat = 'Ymd-H';

	/**
	 * 设置文件名日期格式
	 *
	 * @param string $logNameFormat
	 */
	static public function setNameFormat($logNameFormat) {
		$logger = self::_getInstance();
		$logger->logNameFormat = $logNameFormat;
	}

	/**
	 * 写日志
	 * @param string $msg
	 * @param string $flag success/error
	 */
	static public function write($msg, $flag = '') {
		$logger = self::_getInstance();
		$log = $logger->_log($msg) . "\n";
		$logger->_append($log, $flag);
	}

	/**
	 * 写错误日志
	 * @param string $msg
	 */
	static public function error($msg) {
		$logger = self::_getInstance();
		$log = $logger->_log($msg) . "\n";
		$logger->_append($log, 'error');
	}

	/**
	 * 显示日志
	 * @param string $msg
	 * @return void
	 */
	static public function show($msg) {
		$logger = self::_getInstance();
		echo $logger->_log($msg) . "<br>\n";
	}

	/**
	 * 写日志/显示日志
	 * @param string $msg
	 * @param string $file
	 * @return void
	 */
	static public function tee($msg, $flag = '') {
		$logger = self::_getInstance();
		$log = $logger->_log($msg);
		$logger->_append($log . "\n", $flag);
		echo $log . "<br>\n";
	}

	/**
	 * 组合日志信息
	 * @param string $msg
	 * @return string
	 */
	private function _log($msg) {
		$flag = "\t\t\t";
		$msg = str_replace(array("\r", "\n", "\t", '  '), ' ', $msg);
		$ip = $_SERVER['SERVER_ADDR'] ? $_SERVER['SERVER_ADDR'] : '0.0.0.0';
		$log = "<[" . date('Y-m-d H:i:s') . "]>{$flag}";
		$log .= "<[$ip]>{$flag}";
		$log .= "<[$msg]>{$flag}";
		$log .= "<[From:";

		// 记录错误发生的过程
		$bugInfo = debug_backtrace();
		unset($bugInfo[0]);
		krsort($bugInfo);
		foreach ($bugInfo as $row) {
			if ($row['function'] == 'call_user_func_array' || $row['function'] == '__call' || !$row['line']) {
				continue;
			}
			foreach ($row['args'] as $k => $v) {
				is_object($v) ? $v = 'object' : false;
				$row['args'][$k] = str_replace(array("\r", "\n", "\t", '\\', '\'', '  '), ' ', var_export($v, 1));
			}
			$file = basename($row['file']);
			$args = implode(', ', $row['args']);
			$log .= " {$file}-L{$row['line']} {$row['class']}{$row['type']}{$row['function']}($args);;";
		}
		$log .= "]>";

		return $log;
	}

	/**
	 * 将内容追加到日志文件中
	 * @param string $msg
	 * @param string $file
	 * @return boolean
	 */
	private function _append($msg, $flag) {
		$logger = self::_getInstance();
		if (!MooFile::isExists($logger->logDir)) {
			MooFile::mkDir($logger->logDir);
		}

		$file = $logger->logDir . '/' . $flag . '/' . date('Y-m-d') . '/' . date($logger->logNameFormat) . '.log';

		// 如果文件夹不存在，则创建一个
		if (!MooFile::isExists(dirname($file))) {
			MooFile::mkDir(dirname($file));
		}

		return MooFile::write($file, $msg, true);
	}

	/**
	 * 单例实现对象
	 * @return object
	 */
	static private function _getInstance() {
		if (is_object($this) && $this instanceof MooLog) {
			return $this;
		}
		static $logger = null;
		if (!$logger) {
			$logger = new MooLog();
		}
		return $logger;
	}
}