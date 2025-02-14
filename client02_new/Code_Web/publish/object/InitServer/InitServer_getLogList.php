<?php
class InitServer_getLogList {

	function getLogList() {
		
		$returnData = array();
		
		$logDao = MooDao::get('InitServerLog');
		$sql = "SELECT * FROM @TABLE ORDER BY  `log_time` DESC ";
		$logList = $logDao->getAll($sql);
		
		if (!$logList) {
			return $returnData;
		}
		
		foreach ($logList as $info) {
			$tmp = array();
			$tmp['id'] = $info['log_id'];
			$tmp['gameName'] = $info['log_game_name'];
			$tmp['platforms'] = $info['log_platforms'];
			$tmp['version'] = $info['log_version'];
			$tmp['serverName'] = $info['log_server_name'];
			$tmp['number'] = $info['log_number'];
			$tmp['date'] = $info['log_date'];
			$tmp['time'] = $info['log_time'];
			$tmp['manager'] = $info['log_user'];
			$returnData[] = $tmp;
		}

		return $returnData;
	}
}