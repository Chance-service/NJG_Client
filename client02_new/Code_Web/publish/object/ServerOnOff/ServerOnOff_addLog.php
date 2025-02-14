<?php
class ServerOnOff_addLog {

	function addLog($gameName, $platforms, $serverId, $serverName, $type, $version, $manager, $nowDateTime) {

		$nowTime = strtotime($nowDateTime);
		$nowDate = date('Y-m-d', $nowTime);
		
		$logDao = MooDao::get('ServerOnOffLog');
		$logObj = $logDao->load(array('log_server_id' => $serverId, 'log_date' => $nowDate, 'log_user' => $manager, 'log_type' => $type));
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
			$logDao->setData('log_type', $type);
			$logDao->setData('log_number', 1);
			$logDao->setData('log_date', $nowDate);
			$logDao->setData('log_time', $nowTime);
			$logDao->setData('log_user', $manager);
			$logDao->insert();
		}

		return true;
	}
}