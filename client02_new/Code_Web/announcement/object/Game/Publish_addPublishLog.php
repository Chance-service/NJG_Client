<?php
class Publish_addPublishLog {

	function addPublishLog($gameName, $platforms, $serverId, $serverName, $version, $publishUser) {

		$nowDate = date('Y-m-d');
		$nowTime = time();
		
		$logDao = MooDao::get('Log');
		$logObj = $logDao->load(array('log_server_id' => $serverId, 'log_date' => $nowDate, 'log_publish_user' => $publishUser));
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
			$logDao->setData('log_publish_user', $publishUser);
			$logDao->insert();
		}

		return true;
	}
}