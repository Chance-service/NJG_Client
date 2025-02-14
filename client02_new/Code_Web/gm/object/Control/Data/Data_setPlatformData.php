<?php
class Control_Data_setPlatformData {

	function setPlatformData($game) {
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
		$platformInfo = $gameConf[$game];
		
		MooView::set('nowGame', $game);
		MooView::set('platforms', $platformInfo['platform']);
		MooView::set('channels', $platformInfo['channel']);
	}
}