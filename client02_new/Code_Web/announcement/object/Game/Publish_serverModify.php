<?php
class Publish_serverModify {

	function serverModify() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageServer'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		$serverId = MooForm::request('serverId');
		$gameId = MooForm::request('gameId');
		$platforms = MooForm::request('platforms');
		$serverTag = MooForm::request('serverTag');
		$serverName = MooForm::request('serverName');
		$version = MooForm::request('version');
		$onlineServerDir = MooForm::request('onlineServerDir');
		$serverIp = MooForm::request('serverIp');
		$serverUser = MooForm::request('serverUser');
		$sshPort = MooForm::request('sshPort');
		$type = MooForm::request('type');
		
		$serverDao = MooDao::get('Server');
		$serverObj = $serverDao->load($serverId);
		if (!$serverObj) {
			return false;
		}
		if ($type == 'del') {
			$serverObj->delete();
		} else {
		
			$serverObj->set('s_game_id', $gameId);
			$serverObj->set('s_platforms', $platforms);
			$serverObj->set('s_tag', $serverTag);
			$serverObj->set('s_name', $serverName);
			$serverObj->set('s_version', $version);
			$serverObj->set('s_online_dir', $onlineServerDir);
			$serverObj->set('s_ip', $serverIp);
			$serverObj->set('s_user', $serverUser);
			$serverObj->set('s_port', $sshPort);
		}

		return true;
	}
}