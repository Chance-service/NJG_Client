<?php
class Control_Data_fetchStatData {

	function fetchStatData() {
		date_default_timezone_set("UTC");
		$game 		= 	MooForm::request('game');
		$platform 	= 	MooForm::request('platform');			
		$channel	= 	MooForm::request('channel');			
		$startDate 	= 	MooForm::request('startTime');
		$endDate 	= 	MooForm::request('endTime');
		
		$fetch_operationUrl = MooConfig::get('main.url.fetch_statistics');
		
		if($channel) {
			$url = $fetch_operationUrl."?game=".$game."&channel=".$channel."&beginDate=".$startDate."&endDate=".$endDate;
		}elseif($platform) {
			$url = $fetch_operationUrl."?game=".$game."&platform=".$platform."&beginDate=".$startDate."&endDate=".$endDate;
		} else {
			$url = $fetch_operationUrl."?game=".$game."&beginDate=".$startDate."&endDate=".$endDate;
		}
		
		$rs = MooUtil::curl_send($url);	
		$res = MooJson::decode($rs);
		
		if(!$res) {
			$startDate 	= 	date('Y-m-d', time());
			$endDate 	= 	date('Y-m-d', time());
			MooView::set('startDate', $startDate);
			MooView::set('endDate', $endDate);
			/*
			$userNum = '[{"label":"当日付费","data":[["20150201",500],["20150202",800],["20150203",600],["20150204",400],["20150205",600],["20150206",300],["20150207",900]]}]';
			$userNumArr = MooJson::decode($userNum, true);
			MooView::set('userNum', $userNum);
			MooView::set('maRechargeNum', 1000);
			MooView::set('minDate', '20150201');
			MooView::set('maxDate', '20150207');
			MooView::set('dateNum', 7);	
			*/
			
			MooObj::get('Control_Data')->setPlatformData($game);
			
			MooView::set('data1', $res);
			MooView::set('data2', $res);	
			MooView::set('data3', $res);
			MooView::render('dataStatView2');
		}
		
		// 当日付费
		$dayRecharge = array();
		$dayRecharge[0]['label'] = "日付费";
		
		// 当日设备新增
		$deviceAdd = array();
		$deviceAdd[0]['label'] = "日设备新增";
		
		$rechargeNusArr = array();
		$deviceAddArr = array();
		$dates = array();
		
		if($res) {
			foreach ($res as $key => $val) {
				$date = date('Ymd', strtotime($val['date']));
				$rsult[0] = strtotime($date) * 1000;
				$rsult[1] = $val['payMoney'];
				$dates[] =  $date;
				$rechargeNusArr[] = $val['payMoney'];
 				$dayRecharge[0]['data'][] = $rsult;
 				
 				$deviceAddRes[0] 	= strtotime($date) * 1000;;
				$deviceAddRes[1] 	= $val['newDevice'];
				$deviceAddArr[] 	= $val['newDevice'];
 				$deviceAdd[0]['data'][] = $deviceAddRes;
			}
		}
		$dayRecharge['data'] = $dayRecharge[0]['data'];
		$dayRecharge['label']  = "日付费";
		
		$dayRecharge = MooJson::encode($dayRecharge);
		
		$deviceAdd['data'] = $deviceAdd[0]['data'];
		$deviceAdd['label'] = "日设备新增";
	
		$deviceAdd = MooJson::encode($deviceAdd);
		if($rechargeNusArr) {
			$maxNum = max($rechargeNusArr);
		}
		
		$rechargeNusJson = MooJson::encode($rechargeNusArr);
		
		
		if($deviceAddArr) {
			$maxDeviceAddNum = max($deviceAddArr);
		}
		
		$deviceAddJson = MooJson::encode($deviceAddArr);
		
		$maxNum = ceil($maxNum / 100) * 100;
		$maxDeviceAddNum = ceil($maxDeviceAddNum / 100) * 100;
		
		if ($dates) {
			$minDate = min($dates);
			$maxDate = max($dates);
			$dateNum = count($dates) - 1;
		}

		if ($dateNum == 0) {
			$dateNum = 1;
		}
		$startTimes = strtotime($startDate);
		$year = date('Y', $startTimes);
		$month = date('m', $startTimes) - 1;
		$day = date('d', $startTimes);
		
		// 当日充值
		MooView::set('rechargeNums', $rechargeNusJson);
		MooView::set('year', $year);
		MooView::set('month', $month);
		MooView::set('day', $day);
		
		
		MooView::set('dailyRechargeNum', $dayRecharge);
		MooView::set('maRechargeNum', $maxNum);
		MooView::set('minDate', $minDate);
		MooView::set('maxDate', $maxDate);
		MooView::set('dateNum', $dateNum);
		
		
		// 日设备新增
		MooView::set('deviceAddJson', $deviceAddJson);
		
		MooView::set('deviceAdd', $deviceAdd);
		MooView::set('maxDeviceNum', $maxDeviceAddNum);
		MooView::set('minDate', $minDate);
		MooView::set('maxDate', $maxDate);
		
		MooView::set('dateNum', $dateNum);
		
		MooObj::get('Control_Data')->setPlatformData($game);
		MooView::set('platform', $platform);
		MooView::set('channel', $channel);
		
		MooView::set('startDate', $startDate);
		MooView::set('endDate', $endDate);
		
		MooView::set('data', $res);
		MooView::set('data2', $res);	
		MooView::set('data3', $res);
		MooView::set('data4', $res);
		
		MooView::render('dataStatView2');
	}
}