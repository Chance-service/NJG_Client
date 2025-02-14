<?php
class Control_Gm_newly {
	function newly() {
		$action = MooForm::request('action');
		$game 	= MooForm::request('game');
		$server = MooForm::request('selectServer');
		
		$statDate	= MooForm::request('statDate');
		$endDate 	= MooForm::request('endDate');
		if(!$statDate) {
			$statDate = date('Y-m-d');
		}
		if(!$endDate) {
			$endDate = date('Y-m-d');
		}
		// 设置起止时间
		MooView::set('startDate', $statDate);
		MooView::set('endDate', $endDate);
		
		if($action == 0) {
			MooView::render('newly');
		} else {
			// 后台用户名
			$userName = MooObj::get('User')->getUserName();
			$params = array();
			$params['begintime'] 	= $statDate;
			$params['endtime'] 		= $endDate;
			
			$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			if($serverLists) {
				$serverUrl = $serverLists[$server]['url'];
			}
			
			if ($serverUrl) {
				$cmd = "newly";
				$url = MooObj::get('Gm')->getUrl($serverUrl, $cmd, $userName, $params);
				$res = MooUtil::curl_send($url);
				$returnData = MooJson::decode($res, true);
			}
			// 设备新增
			if($returnData['status'] == 1) {
				MooView::set('deviceInfo', $returnData['info']);
			}
			
			$serverLists = MooObj::get('Gm')->getServerListByGame($game);
			
			MooView::set('nowGame', $game);
			MooView::set('nowServer', $server);
			
			MooView::set('serverLists', $serverLists);
			MooView::render('newly');
		}
	}
}