<?php
class Game_getPlatformByGame {

	function getPlatformByGame($game) {
		/*
		$url = MooConfig::get('main.url.fetch_game');
		$result = MooUtil::curl_send($url);
		$resultArr = MooJson::decode($result, true);
		
		v($resultArr);
		
		$gameConf = array();
		if ($resultArr) {
			foreach ($resultArr as $key => $val) {
				$gameConf[$val['game']]['platform'] = explode(',', $val['platform']);
				$gameConf[$val['game']]['channel'] 	= explode(',', $val['channel']);
			}
		}
		$res = $gameConf[$game]['channel'];
		*/
		
		$res = MooConfig::get('platform.' . $game);
		
		return $res;
	}
}