<?php
class Gm_getServerListByGame {
	function getServerListByGame($game) {
		
		/*
		$getServersUrl = MooConfig::get('main.url.fetch_server');
		$url = $getServersUrl . "?game=" . $game;
		$res = MooUtil::curl_send($url);
		$resArr = MooJson::decode($res, true);
		*/
		
		$resArr = MooConfig::get('server.' . $game);
		
		$resData = array();
		if($resArr) {
			foreach ($resArr as $key => $val) {
				$arr['id']		= $key;
				$arr['platform'] = $val['platform'];
				$arr['server'] 	= $val['server'];
				$arr['url'] 	= $val['ip'] . ":" . $val['script_port'];
				$resData[$arr['server']] = $arr;
			}
		} 	
		return  $resData;
	}
}