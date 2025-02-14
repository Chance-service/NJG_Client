<?php
class ServerOnOff_Log_getExecDetail {

	function getExecDetail($gameId = 0, $serverIds = '', $type = '') {
		
		$logData = array();
		
		$logPath = WEB_DIR . "/serverOnOffLog/serverOnOff.log";
		$historyLogPath = WEB_DIR . "/serverOnOffLog/serverOnOff_history.log";
		
		if ($gameId && $serverIds && $type) {
			$nowDateTime = date('YmdHis');
			
			$versionArr = array();
			$publishConfig = MooConfig::get('main.publishVersion');
			foreach ($publishConfig as $key => $value) {
				$versionArr[$value] = $key;
			}
			
			$publishUser = '';
			$publishUserId = MooObj::get('User')->verify();
			$userObj = MooObj::get('User')->getUser($publishUserId);
			if ($userObj) {
				$publishUser = $userObj->user_name;
			}
			
			$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
			
			$serverIdArr = explode(',', $serverIds);
			$serverList = MooObj::get('Publish')->getServerList($gameId, $serverIdArr);
			
			$publishQueue = $publishQueueVersion = array();
			$serverOnOffQueueString = '';
			// lol release s2 /www/wwwroot/demacia/qimi/release/s2/ on root 127.0.0.1 22
			$versionList = array();
			foreach ($serverList as $info) {
				$versionList[$info['version']] = $info['version'];
				$serverOnOffQueueString .= "{$gameInfo['gameTag']} {$versionArr[$info['version']]} {$info['tag']} {$info['onlineServerDir']} {$type} {$info['serverUser']} {$info['serverIp']} {$info['sshPort']}\n";
				MooObj::get('ServerOnOff')->addLog($gameInfo['gameName'], $info['platforms'], $info['id'], $info['name'], $type, $versionArr[$info['version']], $publishUser, $nowDateTime);
			}
			MooFile::write(WEB_DIR . "/serverOnOffQueueMonitor/".$gameInfo['gameTag']."_queue.log", $serverOnOffQueueString);
			
			$logData['isPublishIng'] = 1;
			$isExists = MooFile::isExists($logPath);
			if ($isExists) {
				$log = MooFile::readAll($logPath);
			} else {
				if ($type == 'on') {
					$log = '开服 ing ...';
				} elseif ($type == 'off') {
					$log = '停服 ing ...';
				} else {
					$log = '无缝重启服 ing ...';
				}
			}
			
		} else {
			$isExists = MooFile::isExists($logPath);
			if ($isExists) {
				$logData['isPublishIng'] = 1;
				$log = MooFile::readAll($logPath);
			} else {
				$logData['isPublishIng'] = 0;
				$log = MooFile::readAll($historyLogPath);
			}
		}
		$log = htmlspecialchars($log);
		
		$log = str_replace("\n", "<br/>", $log);
		$logData['log'] = $log;

		return $logData;
	}
}