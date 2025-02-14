<?php
class Publish_platformModify {

	function platformModify() {
	// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['managePlatform'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		$platformId = MooForm::request('platformId');
		$type = MooForm::request('type');
		$platformTag = MooForm::request('platformTag');
		$platformName = MooForm::request('platformName');
		
		$platformDao = MooDao::get('Platform');
		$platformObj = $platformDao->load($platformId);
		if (!$platformObj) {
			return false;
		}
		if ($type == 'del') {
			$platformObj->delete();
		} else {
		
			$platformObj->set('pl_tag', $platformTag);
			$platformObj->set('pl_name', $platformName);
		}

		return true;
	}
}