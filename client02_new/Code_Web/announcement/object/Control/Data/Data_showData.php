<?php
class Control_Data_showData {

	function showData() {
		
		$nowGame = MooConfig::get('main.nowGame');
		$gameInfo = MooDao::get('Game')->load(array('game_tag' => $nowGame));
		
		// 用户id
		$uId = MooObj::get('User')->verify();
		$user = MooDao::get('User')->load($uId);
		$myAreaInfo = $user->user_areas;
		$areaArrs = explode('|', $myAreaInfo);
		
		if($areaArrs[0]) {
			$areaInfoArr = explode(',',$areaArrs[0]);
			MooView::set('areaInfoArr', $areaInfoArr);
		}
		
		MooView::set('nowGame', $nowGame);
	
		MooView::render('notices');
	}
}