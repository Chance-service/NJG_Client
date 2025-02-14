<?php
class Publish_addServer {

	function addServer() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageServer'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		$gameId = MooForm::request('gameId');
		$platforms = MooForm::request('platforms');
		$serverTag = MooForm::request('serverTag');
		$serverName = MooForm::request('serverName');
		$version = MooForm::request('version');
		$onlineServerDir = MooForm::request('onlineServerDir');
		$serverIp = MooForm::request('serverIp');
		$serverUser = MooForm::request('serverUser');
		$sshPort = MooForm::request('sshPort');
		
		$serverDao = MooDao::get('Server');
		$serverDao->setData('s_game_id', $gameId);
		$serverDao->setData('s_platforms', $platforms);
		$serverDao->setData('s_tag', $serverTag);
		$serverDao->setData('s_name', $serverName);
		$serverDao->setData('s_version', $version);
		$serverDao->setData('s_online_dir', $onlineServerDir);
		$serverDao->setData('s_ip', $serverIp);
		$serverDao->setData('s_user', $serverUser);
		$serverDao->setData('s_port', $sshPort);
		$serverDao->setData('s_time', time());
		$serverDao->insert();

		return true;
	}
}