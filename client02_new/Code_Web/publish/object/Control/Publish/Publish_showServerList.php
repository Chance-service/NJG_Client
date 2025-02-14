<?php
class Control_Publish_showServerList {

	function showServerList() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageServer'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		$gameInfo = array();
		$gameList = MooObj::get('Publish')->getGameList();
		if ($gameList) {
			foreach ($gameList as $tmpInfo) {
				$gameInfo[$tmpInfo['id']] = $tmpInfo['name'];
			}
		}
		
		$platformInfo = array();
		$platformList = MooObj::get('Publish')->getPlatformList();
		if ($platformList) {
			foreach ($platformList as $tmpInfo) {
				$platformInfo[$tmpInfo['id']] = $tmpInfo['name'];
			}
		}
		
		$versionInfo = array();
		$publishVersionList = MooConfig::get('main.publishVersion');
		foreach ($publishVersionList as $key => $value) {
			$versionInfo[$value] = $key;
		}
		
		$serverList = array();
		$serverListInfo = MooObj::get('Publish')->getServerList();
		if ($serverListInfo) {
			foreach ($serverListInfo as $tmpInfo) {
				$tmp = array();
				$tmpInfo['gameName'] = $gameInfo[$tmpInfo['gameId']];
				unset($tmpInfo['gameId']);
				$tmpArr = explode(',', $tmpInfo['platforms']);
				unset($tmpInfo['platforms']);
				foreach ($tmpArr as $pId) {
					$tmp[] = $platformInfo[$pId];
				}
				$tmpInfo['platformsName'] = implode(',', $tmp);
				$tmpInfo['version'] = $versionInfo[$tmpInfo['version']];
				
				$serverList[] = $tmpInfo;
			}
		}
		
		MooView::set('serverList', $serverList);
		MooView::render('serverList');
	}
}