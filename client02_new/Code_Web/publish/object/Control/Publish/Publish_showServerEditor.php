<?php
class Control_Publish_showServerEditor {

	function showServerEditor() {
		
		$serverId = MooForm::request('serverId');
		$serverInfo = MooObj::get('Publish')->getServerInfo($serverId);
		if (!$serverInfo) {
			exit('找不到该服务器');
		}
		MooView::set('nowGameId', $serverInfo['gameId']);
		MooView::set('haveSelPlatform', $serverInfo['platforms']);
		MooView::set('serverTag', $serverInfo['serverTag']);
		MooView::set('serverName', $serverInfo['serverName']);
		MooView::set('nowVersionId', $serverInfo['version']);
		MooView::set('onlineServerDir', $serverInfo['onlineServerDir']);
		MooView::set('serverIp', $serverInfo['serverIp']);
		MooView::set('serverUser', $serverInfo['serverUser']);
		MooView::set('sshPort', $serverInfo['sshPort']);
		MooView::set('serverId', $serverId);
		
		$gameList = MooObj::get('Publish')->getGameList();
		if ($gameList) {
			MooView::set('gameList', $gameList);
		}
		
		$platformList = MooObj::get('Publish')->getPlatformList();
		if ($platformList) {
			MooView::set('platformList', $platformList);
		}
		
		$versionList = array();
		$publishVersionList = MooConfig::get('main.publishVersion');
		foreach ($publishVersionList as $key => $value) {
			$tmp = array();
			$tmp['id'] = $value;
			$tmp['name'] = $key;
			$versionList[] = $tmp;
		}
		MooView::set('versionList', $versionList);
		MooView::render('editorServer');
	}
}