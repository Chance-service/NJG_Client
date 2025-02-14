<?php
class Control_Game_getPlatformByGame {

	function getPlatformByGame() {
		$game 		= MooForm::request('game');
		$url = MooConfig::get('main.url.fetch_game');
		$result = MooUtil::curl_send($url);
		$resultArr = MooJson::decode($result, true);
		$gameConf = array();
		if ($resultArr) {
			foreach ($resultArr as $key => $val) {
				$gameConf[$val['game']]['platform'] = explode(',', $val['platform']);
				$gameConf[$val['game']]['channel'] 	= explode(',', $val['channel']);
			}
		}
		$res = $gameConf[$game];
		$rs = MooJson::encode($res);
		exit($rs);
	}
}