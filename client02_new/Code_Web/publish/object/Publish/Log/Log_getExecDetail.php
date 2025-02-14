<?php
class Publish_Log_getExecDetail {

	function getExecDetail($gameId = 0, $serverIds = '') {
		
		$logData = array();
		
		$logPath = WEB_DIR . "/publishLog/publish.log";
		$historyLogPath = WEB_DIR . "/publishLog/publish_history.log";
		
		if ($gameId && $serverIds) {
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
			$publishQueueString = $publishQueueVersionString = '';
			// lol release 20140618151035 https://192.168.1.208/lol_server_compile/trunk forbidden 123456
			// lol release s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22
			$versionList = array();
			foreach ($serverList as $info) {
				$versionList[$info['version']] = $info['version'];
				$publishQueueString .= "{$gameInfo['gameTag']} {$versionArr[$info['version']]} {$info['tag']} {$info['onlineServerDir']} {$info['serverUser']} {$info['serverIp']} {$info['sshPort']}\n";
				MooObj::get('Publish')->addPublishLog($gameInfo['gameName'], $info['platforms'], $info['id'], $info['name'], $versionArr[$info['version']], $publishUser);
			}
			foreach ($versionArr as $key => $value) {
				if ($versionList[$key]) {
					$publishQueueVersionString .= "{$gameInfo['gameTag']} {$value} {$nowDateTime} {$gameInfo['checkoutUrl']} {$gameInfo['svnUserName']} {$gameInfo['svnPassword']}\n";
				}
			}
			MooFile::write(WEB_DIR . "/publishQueueMonitor/" . $gameInfo['gameTag'] . "_queueVersion.log", $publishQueueVersionString);
			MooFile::write(WEB_DIR . "/publishQueueMonitor/" .$gameInfo['gameTag']. "_queue.log", $publishQueueString);
			
			$logData['isPublishIng'] = 1;
			$isExists = MooFile::isExists($logPath);
			if ($isExists) {
				$log = MooFile::readAll($logPath);
			} else {
				$log = '发布 ing ...';
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
		$log = str_replace("/s    ", "/s<br/>", $log);
		$log = str_replace("\n", "<br/>", $log);
		$logData['log'] = $log;

		return $logData;
	}
}