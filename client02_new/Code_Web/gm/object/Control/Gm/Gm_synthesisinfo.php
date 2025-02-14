<?php
class Control_Gm_synthesisinfo {
	function synthesisinfo() {
		$action = MooForm::request('action');
		$game 	= MooForm::request('game');
		$server = MooForm::request('selectServer');
		
		$date 	= MooForm::request('date');
		if(!$date) {
			$date = date('Y-m-d');
		}
		MooView::set('selectDate', $date);
		if($action == 0) {
			MooView::render('synthesisinfo');
		} else {
			// 后台用户名
			$userName = MooObj::get('User')->getUserName();
			$params = array();
			$params['date'] = $date;
			$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			if($serverLists) {
				$serverUrl = $serverLists[$server]['url'];
			}
			
			if ($serverUrl) {
				$cmd = "synthesisinfo";
				$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
					
				$res = MooUtil::curl_send($url);
				$returnData = MooJson::decode($res, true);
					
				MooView::set('status', $returnData['status']);
				MooView::set('date', $returnData['date']);
				MooView::set('online', $returnData['online']);
				MooView::set('totalUsers', $returnData['totalUsers']);
				MooView::set('totalDevice', $returnData['totalDevice']);
				MooView::set('totalPayUsers', $returnData['totalPayUsers']);
				MooView::set('totalPayDevice', $returnData['totalPayDevice']);
				MooView::set('totalPayMoney', $returnData['totalPayMoney']);
				MooView::set('newUsers', $returnData['newUsers']);
				MooView::set('newDevice', $returnData['newDevice']);
				MooView::set('dailyActiveUsers', $returnData['dailyActiveUsers']);
				MooView::set('userRetentionRate', $returnData['userRetentionRate']);
				MooView::set('deviceRetentionRate', $returnData['deviceRetentionRate']);
				MooView::set('payUsers', $returnData['payUsers']);
				MooView::set('payDevice', $returnData['payDevice']);
				MooView::set('payMoney', $returnData['payMoney']);
			}
			
			$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
			MooView::set('nowGame', $game);
			MooView::set('nowServer', $server);
			
			MooView::set('serverLists', $serverLists);
			MooView::render('synthesisinfo');
		}
	}
}