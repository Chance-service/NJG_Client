<?php
// index.php?mod=Game&do=getLangByAreaGame&game=areaName=" + areaName
class Control_Game_getLangByAreaGame {

	function getLangByAreaGame() {
		$game			= MooForm::request('game');
		$areaName		= MooForm::request('areaName');
		$gameInfo = MooDao::get('Game')->load(array('game_tag' => $game));
		$langInfo = $gameInfo->game_lang;

		if($langInfo) {
		
			$langInfoArrs = explode('|', $langInfo);
			$results = array(); 
			foreach ($langInfoArrs as $k => $v) {
				$langInfoArr = explode('_',  $v);
				$langs[$langInfoArr[0]] = $langInfoArr[1];
				$conf['platform'] = explode("," , $langs[$areaName]);
				$rs = MooJson::encode($conf);
				$results[$langInfoArr[0]] = $rs;
			}
             
			 if($results[$areaName]) {
			     	exit($results[$areaName]);
			 } else {
				 $conf['platform'] = "";
				$rs = MooJson::encode($conf);
				exit($rs);
			 }
		} else {
			$conf['platform'] = "";
			$rs = MooJson::encode($conf);
			exit($rs);
		}
	}
}
