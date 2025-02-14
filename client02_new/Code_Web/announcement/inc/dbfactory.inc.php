<?php
// 全局数据库
class announceDB extends MooDBTable {
	function __construct() {
		$this->_setAdapter(DBFactory::dbConnect('announce'));
	}
}

class DBFactory {

	static private $db = array();

	static public function dbConnect($dbName) {
		$db = $dbName;
		if (!is_object(self::$db[$db])) {
			$dbConfig = MooConfig::get("dbconfig.{$dbName}");
			$errDir = MOOLOG_LOG_DIR . "/dblog/{$dbName}";
			self::$db[$db] = self::_factory($dbConfig['host'], $dbConfig['user'], $dbConfig['pwd'], $dbConfig['dbName'], $dbConfig['char'], $errDir);
		}
		return self::$db[$db];
	}

	static protected function _factory($host, $user, $pwd, $dbname, $char, $errDir) {

		$dbConfig = MooConfig::get('dbconfig');
		if ((MooForm::request('print') == 'yes' && defined('MOOPHP_DEBUG') && MOOPHP_DEBUG) ) {
			require_once LIB_PATH . '/MooDBDebug.lib.php';
			$db = new MooDBDebug($host, $user, $pwd, $dbname, $char, $errDir, 1000, $dbConfig['connect']['pconnect'], $dbConfig['connect']['selectDb']);
		} else {
			$db = new MooDB($host, $user, $pwd, $dbname, $char, $errDir, 1000, $dbConfig['connect']['pconnect'], $dbConfig['connect']['selectDb']);
		}
		return $db;
	}
}
