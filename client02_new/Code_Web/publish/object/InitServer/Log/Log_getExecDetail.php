<?php
class InitServer_Log_getExecDetail {

	function getExecDetail($gameId = 0, $serverIds = '') {
		
		$logData = array();
		
		$logPath = WEB_DIR . "/initServerLog/initServer.log";
		$historyLogPath = WEB_DIR . "/initServerLog/initServer_history.log";
		
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
			$initServerQueueString = '';
			// 队列格式：游戏 区服 服务器web目录 服务器用户名 服务器ip 服务器端口号(lol s2 /www/wwwroot/demacia/qimi/release/s2/ root 127.0.0.1 22)
			$versionList = array();
			foreach ($serverList as $info) {
				$versionList[$info['version']] = $info['version'];
				$initServerQueueString .= "{$gameInfo['gameTag']} {$info['tag']} {$info['onlineServerDir']} {$info['serverUser']} {$info['serverIp']} {$info['sshPort']}\n";
				MooObj::get('InitServer')->addLog($gameInfo['gameName'], $info['platforms'], $info['id'], $info['name'], $versionArr[$info['version']], $publishUser, $nowDateTime);
			}
			MooFile::write(WEB_DIR . "/initServerQueueMonitor/" .$gameInfo['gameTag']. "_queue.log", $initServerQueueString);
			
			$logData['isPublishIng'] = 1;
			$isExists = MooFile::isExists($logPath);
			if ($isExists) {
				$log = MooFile::readAll($logPath);
			} else {
				$log = '初始化服务器 ing ...';
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