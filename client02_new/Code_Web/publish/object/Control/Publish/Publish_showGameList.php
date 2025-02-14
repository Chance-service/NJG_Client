<?php
class Control_Publish_showGameList {

	function showGameList() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageGame'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		$gameList = MooObj::get('Publish')->getGameList();
		
		if ($gameList) {
			MooView::set('gameList', $gameList);
		}
		
		MooView::render('gameList');
	}
}