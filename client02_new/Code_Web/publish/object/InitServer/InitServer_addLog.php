<?php
class InitServer_addLog {

	function addLog($gameName, $platforms, $serverId, $serverName, $version, $manager, $nowDateTime) {

		$nowTime = strtotime($nowDateTime);
		$nowDate = date('Y-m-d', $nowTime);
		
		$logDao = MooDao::get('InitServerLog');
		$logObj = $logDao->load(array('log_server_id' => $serverId, 'log_date' => $nowDate, 'log_publish_user' => $manager));
		if ($logObj) {
			$number = $logObj->log_number + 1;
			$logObj->set('log_number', $number);
			$logObj->set('log_time', $nowTime);
		} else {
			$logDao->setData('log_game_name', $gameName);
			$logDao->setData('log_platforms', $platforms);
			$logDao->setData('log_version', $version);
			$logDao->setData('log_server_id', $serverId);
			$logDao->setData('log_server_name', $serverName);
			$logDao->setData('log_number', 1);
			$logDao->setData('log_date', $nowDate);
			$logDao->setData('log_time', $nowTime);
			$logDao->setData('log_publish_user', $manager);
			$logDao->insert();
		}

		return true;
	}
}