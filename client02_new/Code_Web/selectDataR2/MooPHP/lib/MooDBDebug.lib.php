<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 数据库调试类
 * 
 * expample:
 * 实力化这个对象即可。本类所有方法无须手工调用。
 * 
 */
final class MooDBDebug extends MooDB {
	private $debug;

	function __destruct() {
		global $_MooPHP;

		if (class_exists('MooDaoRegister')) {
			$mooDaoreg = MooDaoRegister::factory();
			$mooDaoreg->destruct();
		}
		if (!is_object($this->debug)) {
			$this->debug = new MooDBDebugSql();
		}

		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		$uId = $hashData['uId'];

		$debugDatabaseArr = $this->debug();
		$_MooPHP['debug']['database'][] = $debugDatabaseArr['debugStr'];
		$_MooPHP['debug']['main']['sqlNum'] += $debugDatabaseArr['num'];
		$_MooPHP['debug']['file'] = get_included_files();
		$_MooPHP['debug']['request'] = (defined('SERVER_ID') && SERVER_ID) ? MooObj::get('Api_Cocos2d')->request : NULL;
		MooCache::set($uId.'_MooPHPDebugInfo', $_MooPHP['debug']);
	}

	/**
	 * 调用$this->db对象的方法来执行sql语句，并将返回值返回
	 *
	 * @param string	$sql
	 * @param array		$param
	 * @param boolean	$exit
	 * @param boolean	$cache
	 * @return mix
	 */
	public function query($sql, $param = array(), $exit = true, $cache = 0, $cacheDir = '') {
		if (!preg_match('/^EXPLAIN/i', trim($sql))) {
			$startTime = $this->microtimeFloat();
		}
		
		if (!is_object($this->debug)) {
			$this->debug = new MooDBDebugSql();
		}

		// 调用父类的_callQuery方法
		$rs = parent::query($sql, $param, $exit, $cache, $cacheDir);
		$isCached = is_object($rs) && ($rs->getResType() == 'ARRAY') ? true : false;

		if (!preg_match('/^EXPLAIN/i', trim($sql))) {
			$this->debug->debugSql(array('time' => sprintf('%0.6f', ($this->microtimeFloat() - $startTime) * 1000), 'sql' => parent::_prepare($sql, $param), 'useCache' => $cache, 'isCached' => $isCached, 'serverId' => $this->config['hostname']));
		}
		return $rs;
	}

	/**
	 * 退出程序,并输出提示信息
	 *
	 * @param string $msg
	 */
	protected function _exit($msg) {
		// 错误信息
		$error = $this->getError();
		$errStr = "Error Date:\t" . date('Y-m-d h:i:s', time()) . "\n";
		$errStr .= "Error MSG:\t{$msg}\n";
		$error ? $errStr .= "Error Content:\t{$error}\n" : TRUE;
		$errStr .= "Error IP:\t{$_SERVER['SERVER_ADDR']}\n";
		$errStr .= "Error File:\n";
		// 错误发生的过程
		$bugInfo = debug_backtrace();
		unset($bugInfo[0]);
		unset($bugInfo[1]);
		krsort($bugInfo);
		foreach ($bugInfo as $row) {
			foreach ($row['args'] as $k => $v) {
				is_object($v) ? $v = 'object' : false;
				$row['args'][$k] = str_replace(array("\r", "\n", "\t", '  '), ' ', (string)$v);
			}
			$args = implode(', ', $row['args']);
			$errStr .= "\t{$row['class']}{$row['type']}{$row['function']}($args), \n\t\tIn File {$row['file']}, \n\t\tOn Line {$row['line']}\n";
		}
		$errFile = $this->errDir . '/' . date('Y-m-d') . '.dberr.php';

		exit('<pre style="font-size:13px">' . $errStr . '</pre>');
	}

	/**
	 * Debug the SQL
	 *
	 */
	private function debug() {
		$debugsql = $this->debug->debugSql();
		if (!$debugsql) {
			return false;
		}

		$debug = '';
		$i = $time = 0;
		$tmp = array();

		foreach ($debugsql as $sqlArr) {
			$time += $sqlArr['time'];
			$sql = $sqlArr['sql'];
			$color = $sqlArr['time'] < 100 ? 'green' : 'red';
			$cache = $sqlArr['useCache'];
			$isCache = $sqlArr['isCached'];
			$serverId = $sqlArr['serverId'];
			$timeStr = "<span style='color:{$color}'><b>" . sprintf('%0.6f', $sqlArr['time']) . "</b></span>";
			$i++;
			// 如果是SELECT语句，才可以执行explain
			if (preg_match("/^SELECT/i", trim($sql))) {
				if ($cache) {
					$color = $isCache ? 'blue' : 'green';
					$debug .= "<tr><th>$i</th><td colspan='9' style='color:{$color};text-align:left'>[Cache: {$cache}]{$sql}</td><td>{$timeStr}</td></tr>\n";
				} else {
					$debug .= "<tr><th>$i</th><td colspan='9' style='color:green;text-align:left'>{$serverId}:{$sql}</td><td >{$timeStr}</td></tr>\n";
				}
				$query = parent::query('EXPLAIN ' . $sql, NULL, false);
				if (!$query) {
					$debug .= '<tr><td></td><td bgcolor="#cccccc" colspan="11" style="color:red">' . parent::getError() . '</td></tr>';
					continue;
				}
				while (false != ($res = $query->fetch())) {
					$debug .= '<tr><td></td><td bgcolor="#cccccc">' . implode('&nbsp;</td><td style="overflow:hidden;" bgcolor="#cccccc">', $res) . '&nbsp;</td></tr>';
					$tmp = $res;
				}
			} else {
				if ($cache) {
					$color = $isCache ? '#000' : '#ccc';
					$debug .= "<tr><th>$i</th><td colspan='9' style='color:{$color};text-align:left'>[Cache: {$cache}]{$sql}</td><td>{$timeStr}</td></tr>\n";
				} else {
					$debug .= "<tr><th>$i</th><td colspan='9' style='color:#999999;text-align:left'>{$serverId}:$sql</td><td>{$timeStr}</td></tr>\n";
				}
			}
		}

		$titleArr = $tmp ? array_keys($tmp) : array('sql');
		$time = sprintf('%0.6f', $time);

		$debugStr .= "<table class=\"moodebugtable2\">\n";
		$debugStr .= "<tr><th width=\"20\">&nbsp;</th><th>" . implode('</th><th style="overflow:hidden;">', $titleArr) . "</th></tr>" . $debug;
		$debugStr .= "</table>";
		$color = $time < 50 ? 'green' : 'red';

/*
		if (function_exists('memory_get_usage')) {
			$memory = memory_get_usage(true) / 1024 / 1024; // 内存使用情况
			$debugStr .= "<tr><td align='right' colspan='11'><b>Memory Use:</b> {$memory}MB&nbsp;&nbsp;<b>SQL TIME:</b> {$time}&nbsp;&nbsp;</td></tr>";
		}
		
		$debugStr .= $this->showFiles() . "</table></div>";
*/
		$returnData['debugStr'] = $debugStr;
		$returnData['num'] = $i;
		return $returnData;
	}

	function showFiles() {
		return '';
		$files = get_included_files();
		if($files) {
			$DebugInfo .= '<table>';
			foreach ($files as $key => $file) {
				$DebugInfo .= '<tr><th width="20">'.($key+1).'</th><td>'.$file.'</td></tr>';
			}
			$DebugInfo .= '</table>';
		}
		return $DebugInfo;
	}

	/**
	 * 计算执行时间
	 *
	 * @return float
	 */
	public function microtimeFloat() {
		$usec = $sec = null;
		list($usec, $sec) = explode(" ", microtime());
		return ((float)$usec + (float)$sec);
	}
}
class MooDBDebugSql {
	public $debugSql = array();
	function debugSql($sql = array()) {
		if ($sql) {
			$this->debugSql[] = $sql;
		} else {
			return $this->debugSql;
		}
	}
}
