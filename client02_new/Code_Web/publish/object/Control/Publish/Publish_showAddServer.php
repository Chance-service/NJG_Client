<?php
class Control_Publish_showAddServer {

	function showAddServer() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageServer'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
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
		MooView::render('addServer');
	}
}