<?php
class Control_DataAnalysis_goldSource {

	function goldSource() {
		$game 		= 	MooForm::request('game');
		$platform 	= 	MooForm::request('platform');
		$channel	= 	MooForm::request('channel');
		$startDate 	= 	MooForm::request('startTime');
		$endDate 	= 	MooForm::request('endTime');
		if(!$startDate) {
			$startDate 	= 	date('Y-m-d', time());
		}
		if(!$endDate) {
			$endDate 	= 	date('Y-m-d', time());
		}
		$action 		= 	MooForm::request('action');
		MooView::set('action', $action);
		
		MooView::set('startDate', $startDate);
		MooView::set('endDate', $endDate);
		if($action == 0) {
			MooView::render('goldSource');
		} else if($action == 1) {
			MooObj::get('Control_Data')->setPlatformData($game);
			$urlConf = MooConfig::get('main.dataAnalysis.fetch_gold_source');
			$url = $urlConf . "&game=" . $game . "&beginDate=" . $startDate . "&endDate=" . $endDate;
			if ($platform) {
				$url = $url . "&platform=" . $platform;
			}
			if ($channel) {
				$url = $url . "&channel=" . $channel;
			}

			// $url = "http://182.254.230.39:9001/fetch_gold?game=wow&changetype=1&beginDate=2015-02-28&endDate=2015-03-31&platform=appstore&channel=appstore";
			
			$data = MooUtil::curl_send($url);
			$dataArr = MooJson::decode($data);
			$actionConf = MooConfig::get('action_name.action');
			$totalGolds = 0;
			$goldRates = array();
			if($dataArr) {
				foreach ($dataArr as $key => $val) {
					$totalGolds += $val['gold'];
				}
					
				foreach ($dataArr as $k => $v) {
					if ($actionConf[$v['changeaction']]) {
						$dataArr[$k]['changeaction'] = $actionConf[$v['changeaction']];
					}
					$dataArr[$k]['rateNum'] = MooUtil::getPercent($v['gold'], $totalGolds, true); // 加true 不要百分号
					$dataArr[$k]['rate'] = MooUtil::getPercent($v['gold'], $totalGolds);
				}
					
				foreach ($dataArr as $k => $v) {
					//$goldRates[$v['changeaction']] = $v['rateNum'];
			
					$goldRates[$k][0]= $v['changeaction'];
					$goldRates[$k][1]= $v['rateNum'];
				}
			}
			
			$viewData = MooJson::encode($goldRates);
			// 格式化数据
			$viewData = str_replace(',"',',',$viewData);
			$viewData = str_replace('"]',']',$viewData);
			
			if($platform) {
				MooView::set('platform', $platform);
			}
			if ($channel) {
				MooView::set('channel', $channel);
			}
			
			MooView::set('viewData', $viewData);
			MooView::set('goldSource', $dataArr);
			MooView::render('goldSource');
		} else {
			exit("error!");
		}
	}
}