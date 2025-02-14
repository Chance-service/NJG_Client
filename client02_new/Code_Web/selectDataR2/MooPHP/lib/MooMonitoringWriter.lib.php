<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * 用于监控用户异常数据的类
 *
 */
class MooMonitoringWriter {
	public $logPath;
	public $logs = array();
	
	function setLogPath($path) {
		$stat = self::getInstance();
		$stat->logPath = $path;
	}
	
	function __destruct() {
		self::finish();
	}
	
	function finish() {
		$stat = self::getInstance();
		$log = $stat->logs;
		$stat->logs = array();
		foreach ($log as $val) {
			MooFile::write($val['logPath'], $val['log'], true);
		}
	}
	
	/**
	 * 准备日志的函数
	 *
	 * @param string $uId
	 * @param string $action
	 * @param array $analysisData
	 * @return boolean
	 */
	function prepare($uId, $action, $analysisData = array()) {
		$stat = self::getInstance();

		$log = array();
		$log['time'] = time();
		$log['uId'] = $uId;
		$log['act'] = $action;
		$log['aysD'] = $analysisData;
		$flats = explode('/', $stat->logPath);
		$stat->logs[$flats[4]]['logPath'] = $stat->logPath;
		$stat->logs[$flats[4]]['log'] .= MooJson::encode($log) . "\n";
	}

	/**
	 * 单键
	 *
	 * @return object
	 */
	public function getInstance() {
		if (is_object($this) && $this instanceof MooMonitoringWriter) {
			return $this;
		}
		static $stat = null;
		if (!$stat) {
			$stat = new MooMonitoringWriter();
		}
		return $stat;
	}
}
