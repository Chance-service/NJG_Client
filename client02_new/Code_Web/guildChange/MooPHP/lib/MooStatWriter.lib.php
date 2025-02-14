<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * 用于统计的类
 *
 */
class MooStatWriter {
	public $logPath;
	public $user;
	public $log = '';
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
		$stat->log = '';
		$stat->logs = array();
		foreach ($log as $val) {
			MooFile::write($val['logPath'], $val['log'], true);
		}
	}
	
	function setUser($uId, $uSex = 'UNKNOW', $other = array()) {
		$stat = self::getInstance();
		$user = array('uId' => $uId, 'uSex' => $uSex);
		if ($other) {
			if (is_array($other)) {
				foreach ($other as $k => $v) {
					$user[$k] = $v;
				}
			} else {
				$user[$k] = $v;
			}
		}
		
		$stat->user = $user;
	}
	
	/**
	 * 准备日志的函数
	 *
	 * @param string $uId
	 * @param string $action
	 * @param float $actionNum
	 * @param array $analysisData
	 * @return boolean
	 */
	function prepare($action, $actionNum, $analysisData = array()) {
		$stat = self::getInstance();

		// datetime -- ip -- action -- actionNum -- userData -- analysisData
		$log = array();
		$log['time'] = time();
		$log['ip'] = MooUtil::realIp();
		$log['act'] = $action;
		$log['actN'] = $actionNum;
		$log['user'] = $stat->user;
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
		if (is_object($this) && $this instanceof MooStatWriter) {
			return $this;
		}
		static $stat = null;
		if (!$stat) {
			$stat = new MooStatWriter();
		}
		return $stat;
	}
}
