<?php
class Control_Publish_showPlatformList {

	function showPlatformList() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['managePlatform'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		$platformList = MooObj::get('Publish')->getPlatformList();
		
		if ($platformList) {
			MooView::set('platformList', $platformList);
		}
		
		MooView::render('platformList');
	}
}