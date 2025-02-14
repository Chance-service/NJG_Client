<?php
class Control_Data_fetchOperation {

	function fetchOperation() {
		
		$game 		= 	MooForm::request('game');
		$platform 	= 	MooForm::request('platform');			
		$channel	= 	MooForm::request('channel');			
		$statistics = 	MooForm::request('statistics');			
		$startDate 	= 	MooForm::request('startTime');
		$endDate 	= 	MooForm::request('endTime');
		
		$fetch_operationUrl = MooConfig::get('main.url.fetch_operation');
		if ($channel) {
			$url = $fetch_operationUrl."?game=".$game."&channel=".$channel."&statistics=".$statistics."&beginDate=".$startDate."&endDate=".$endDate;
		} else if ($platform) {
			$url = $fetch_operationUrl."?game=".$game."&platform=".$platform."&statistics=".$statistics."&beginDate=".$startDate."&endDate=".$endDate;
		} else {
			$url = $fetch_operationUrl."?game=".$game."&statistics=".$statistics."&beginDate=".$startDate."&endDate=".$endDate;
		}
		
		$rs = MooUtil::curl_send($url);	
		$res = MooJson::decode($rs);
		
		MooObj::get('Control_Data')->setPlatformData($game);
		
		MooView::set('nowGame', $game);
		MooView::set('platform', $platform);
		MooView::set('channel', $channel);
		MooView::set('statistics', $statistics);
		
		MooView::set('startDate', $startDate);
		MooView::set('endDate', $endDate);
		
		MooView::set('data', $res);
		MooView::set('data2', $res);	
		MooView::set('data3', $res);
		MooView::set('data4', $res);
		
		MooView::render('dataView2');
	}
}