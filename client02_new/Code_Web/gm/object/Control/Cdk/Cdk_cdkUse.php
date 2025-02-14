<?php
class Control_Cdk_cdkUse {

	function cdkUse() {
		$cdk = MooForm::request("cdk");
		if (!$cdk) {
			MooView::render('cdkUse');
		} else {
			MooView::set('cdk', $cdk); // 查询的cdk
		 	$cdkUrl = MooConfig::get('main.cdkUrl');
			$useCdkUrl = $cdkUrl . "/" . "query_cdk?" . "cdk=" . $cdk;
			$res = MooUtil::curl_send($useCdkUrl);
			$result = MooJson::decode($res, true);
			// 查询成功
			if($result && $result['status'] == 0) {
				$message = $result['type'];
				$createInfoArr = explode('&',$message); 
				// 该cdk信息
				$messArr = array();
				for($index = 0;$index < count($createInfoArr); $index++) { 
					 $info = $createInfoArr[$index];
					 $infoArr = explode('=',$info);
					 $messArr[$infoArr[0]] =  $infoArr[1];
				} 
				
				$cdkInfos = $result['cdk'];
				$cdkInfosArr = explode('&',$cdkInfos); 
				
				// 查询到的cdk使用情况
				$cdkArr = array();
				for($index = 0;$index < count($cdkInfosArr); $index++) { 
					 $info = $cdkInfosArr[$index];
					 $infoArr = explode('=',$info);
					 $cdkArr[$infoArr[0]] =  $infoArr[1];
				} 
				// 设置查询结果
				MooView::set('cdk', $cdkArr['cdk']);
				MooView::set('game', $cdkArr['game']);
				MooView::set('platform', $cdkArr['platform']);
				MooView::set('server', $cdkArr['server']);
				MooView::set('playerid', $cdkArr['playerid']);
				MooView::set('playername', $cdkArr['playername']);
				MooView::set('usetime', $cdkArr['usetime']);
				MooView::set('reward', $cdkArr['reward']);
				
				MooView::render('cdkUse');				
			} else {
				$errMsg = "该cdk不存在!";
				MooView::set('errorMsg', $errMsg);
				MooView::render('cdkUse');
			}
		}
	}
}