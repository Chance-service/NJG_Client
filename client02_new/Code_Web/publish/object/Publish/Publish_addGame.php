<?php
class Publish_addGame {

	function addGame() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageGame'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}

		$gameTag = MooForm::request('gameTag');
		$gameName = MooForm::request('gameName');
		$checkoutUrl = MooForm::request('checkoutUrl');
		$svnUserName = MooForm::request('svnUserName');
		$svnPassword = MooForm::request('svnPassword');
		
		$gameDao = MooDao::get('Game');
		$gameObj = $gameDao->load(array('game_tag' => $gameTag));
		if ($gameObj) {
			return false;
		}
		
		$gameDao->setData('game_tag', $gameTag);
		$gameDao->setData('game_name', $gameName);
		$gameDao->setData('game_checkout_url', $checkoutUrl);
		$gameDao->setData('game_svn_user_name', $svnUserName);
		$gameDao->setData('game_svn_password', $svnPassword);
		$gameDao->setData('game_time', time());
		$gameDao->insert();

		return true;
	}
}