<?php
class Control_Cdk_resetCdk {

	function resetCdk() {
		
		$game 		= MooForm::request('game');
		$channel 	= MooForm::request('channel');
		$cdkType 	= MooForm::request('cdkType');
		$reward 	= MooForm::request('reward');
		$startTime 	= MooForm::request('startTime');
		$endTime 	= MooForm::request('endTime');
		
		if($startTime) {
			$starttime = date('Ymd', strtotime($startTime)) . "000000";
		} else {
			$starttime = "";
		}
		if($endTime) {
			$endtime = date('Ymd', strtotime($endTime)) . "000000";
		} else {
			$endtime = "";
		}
		$cdkUrl = MooConfig::get('main.cdkUrl');
		if ($channel) {
			if ($startTime && $endTime) {
				$resetCdkUrl = $cdkUrl . "/" . "reset_reward?" . "game=" . $game . "&platform=" . $channel . "&type=" . $cdkType  . "&reward=" . $reward . "&starttime=" . $starttime  . "&endtime=" . $endtime; 
			} else {
				$resetCdkUrl = $cdkUrl . "/" . "reset_reward?" . "game=" . $game . "&platform=" . $channel . "&type=" . $cdkType  . "&reward=" . $reward; 
			}
		} else {
			if ($startTime && $endTime) {
				$resetCdkUrl = $cdkUrl . "/" . "reset_reward?" . "game=" . $game  . "&type=" . $cdkType . "&reward=" . $reward . "&starttime=" . $starttime  . "&endtime=" . $endtime; 
			} else {
				$resetCdkUrl = $cdkUrl . "/" . "reset_reward?" . "game=" . $game  . "&type=" . $cdkType . "&reward=" . $reward; 
			}
		}
		
		$res = MooUtil::curl_send($resetCdkUrl);
		$result = MooJson::decode($res);
		if($result['status'] == 0) {
		   	MooView::set('errorMsg3',"重置cdk成功");
			MooView::render('operateCdk');
		} else {
			MooView::set('errorMsg3',"该cdk类型不存在!");
			MooView::render('operateCdk');
		}
	}
}