<?php
class Control_Data_calculateHistory {

	function calculateHistory() {
		
		$game 		= 	MooForm::request('game');
		$date 	= 	MooForm::request('date');
		
		$daily_analyze = MooConfig::get('main.url.daily_analyze');
		
		$url = $daily_analyze."?game=".$game."&date=".$date;
		
//		v($url);
		$rs = MooUtil::curl_send($url);	
		$res = MooJson::decode($rs);
//		v($res);
//		exit;
		$res = array($res);
		MooView::set('nowGame', $game);
		
		MooView::set('date', $date);
		
		MooView::set('data', $res);
		MooView::set('data2', $res);	
		MooView::set('data3', $res);
		MooView::set('data4', $res);
		
		MooView::render('dataHistoryView2');
	}
}