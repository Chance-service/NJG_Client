<?php
class Control_Data_getPlatformData {

	function getPlatformData() {
		
		$startDate 	= 	date('Y-m-d', time());
		$game = MooForm::request('game');
		$date = MooForm::request('date');
		
		if($game && $date) {
			MooObj::get('Control_Data')->setPlatformData($game);
			$url = MooConfig::get('main.url.fetch_general');
			$getDataUrl = $url . "?game=" . $game . "&date=" . $date . "&type=1";
			
			$platformData = MooUtil::curl_send($getDataUrl);
			$platformDataArr  = MooJson::decode($platformData, true);
			
			// v($platformDataArr);
			// 转换百分数
			foreach($platformDataArr as $key => $val) {
				foreach ($val as $k => $v) {
					if($v >= 0 && $v < 1) {
						if (in_array($k, array("userRetention2", "deviceRetention2", "PayRate"))) {
							$platformDataArr[$key][$k] = ($v*100)."%";
						}
					}
				}
			}
			
			// sprintf(".2f", $n*100).'%';
			
			MooView::set('nowGame', $game);
			MooView::set('startDate', $date);
			MooView::set('platformDataArr', $platformDataArr);
			
			MooView::render('platformData3');
		} else {
			MooView::set('startDate', $startDate);
			MooView::render('platformData3');
		}
	}
}