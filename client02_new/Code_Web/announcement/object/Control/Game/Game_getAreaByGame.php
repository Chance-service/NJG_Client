<?php
class Control_Game_getAreaByGame {

	function getAreaByGame() {
		$game 		= MooForm::request('game');
		$gameLists = MooDao::get('Game')->getAll('select * from @TABLE');
		$index  = 0;
		if($gameLists) {
			foreach($gameLists as $key=>$val) {
				if($val['game_tag'] == $game) {
					$index = $key;
				}
			}
		}
		
		$gameInfo = MooDao::get('Game')->load(array('game_tag' => $game));
		$areaInfo = $gameInfo->game_area;
		
		// 用户id
		$uId = MooObj::get('User')->verify();
		$user = MooDao::get('User')->load($uId);
		$myAreaInfo = $user->user_areas;
		
		$areaArrs = explode('|', $myAreaInfo);
		$gameConf = explode(',', $areaInfo);
		$conf['platform'] = array();
		foreach($gameConf as $key => $val) {
			if(strpos(".".$areaArrs[$index], $val)) {
				$conf['platform'][] = $val;
			}
		}
		
		$rs = MooJson::encode($conf);
		exit($rs);
	}
}