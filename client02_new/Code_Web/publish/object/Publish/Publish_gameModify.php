<?php
class Publish_gameModify {

	function gameModify() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageGame'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		$gameId = MooForm::request('gameId');
		$type = MooForm::request('type');
		$gameTag = MooForm::request('gameTag');
		$gameName = MooForm::request('gameName');
		$checkoutUrl = MooForm::request('checkoutUrl');
		$svnUserName = MooForm::request('svnUserName');
		$svnPassword = MooForm::request('svnPassword');
		
		$gameDao = MooDao::get('Game');
		$gameObj = $gameDao->load($gameId);
		if (!$gameObj) {
			return false;
		}
		if ($type == 'del') {
			$gameObj->delete();
		} else {
		
			$gameObj->set('game_tag', $gameTag);
			$gameObj->set('game_name', $gameName);
			$gameObj->set('game_checkout_url', $checkoutUrl);
			$gameObj->set('game_svn_user_name', $svnUserName);
			$gameObj->set('game_svn_password', $svnPassword);
		}

		return true;
	}
}