<?php
class Control_Recharge_fetchBills {

	function fetchBills() {
		
		$game 	= MooForm::request('game');
		$serverId 	= MooForm::request('serverId');
		
		$beginDate 	= MooForm::request('startTime');
		$endDate 	= MooForm::request('endTime');
		
		$type 	= MooForm::request('type');
		
		$fetchOrder = MooConfig::get('main.rechargeUrl.fetch_bills');
		$serverUrl  = MooConfig::get('main.getServersUrl');
		$servers 	= MooUtil::curl_send($serverUrl);
		
		if(!$servers) {
			$serverIds	= MooConfig::get('main.servers');
		} else {
			$servers = MooJson::decode($servers, true);
			foreach($servers as $key => $val) {
				$serverIds[$key] = $val . "server";
			}
		}
		
		if (!$beginDate) {
			$startDate 	= 	date('Y-m-d', time());
			$endDate 	= 	date('Y-m-d', time());
			
			MooView::set('nowGame', 'hwgj');
			MooView::set('channels', $serverIds);
			
			MooView::set('startDate', $startDate);
			MooView::set('endDate', $endDate);
			MooView::render('fetchBills2');
		} else {
			if($serverId) {
				// 结束时间+1天
				$endDateTrue    = date('Y-m-d', strtotime($endDate) + 86400);
				// 把服截取掉
				$sId = substr($serverId, 0, 1);
				$url = $fetchOrder."?serverId=".$sId."&startDate=".$beginDate."&endDate=".$endDateTrue;
			} else {
				$endDateTrue    = date('Y-m-d', strtotime($endDate) + 86400);
				$url = $fetchOrder."?startDate=".$beginDate."&endDate=".$endDateTrue;
			}
			$rs = MooUtil::curl_send($url);
			$res = MooJson::decode($rs, true);
         		if($res && $type == "daochu") {
				$excelData = array();
				
				$sDate = date("Ymd", strtotime($beginDate));
				$eDate = date("Ymd", strtotime($endDate));
				
				if ($serverId) {
					$name = $serverId . "_"  . $sDate . "_" . $eDate;
				} else {
					$name = $sDate . "_" . $eDate;
				}
				
				$excelRs = array(
			
					0 => array(
						0 => 'Server',
						1 => 'Order ID',
						2 => 'puid',
						3 => 'Diamond',
						4 => 'Amount',
						5 => 'Time',
				));
				
				foreach ($res as $key=>$val) {
					$arr[] = $val[0];
					$arr[] = $val[2];
					$arr[] = $val[3];
					$arr[] = $val[4];
					$arr[] = $val[5];
					$arr[] = $val[6];
					$excelData[] = $arr;
					$arr = array();
				}
				
				$excelData = array_merge($excelRs, $excelData);
				$writeExcelArr[0]['name'] = $name;
				$writeExcelArr[0]['data'] = $excelData;
					
				$excelPath = ROOT_PATH . "/orders/" . $name . ".xls";
				
			    $rs = MooObj::get('Control_ExcelConfMaker_Excel')->write($excelPath, $writeExcelArr);

                $this->downFile($excelPath, $name . ".xls");
				exit;
			}
			
			MooView::set('channels', $serverIds);
			MooView::set('serverId', $serverId);
			
			MooView::set('data', $res);
			MooView::set('nowGame', $game);
			MooView::set('channel', $channel);
			MooView::set('startDate', $beginDate);
			MooView::set('endDate', $endDate);
			MooView::render('fetchBills2');
		}
	}

	 // 下载文件
	 private function downFile($filepath, $fileName) {
		$fp			=	fopen($filepath,"r"); 
		$file_size	=	filesize($filepath); 
		//下载文件需要用到的头 
		header("Content-type: application/octet-stream"); 
		header("Accept-Ranges: bytes"); 
		header("Accept-Length:".$file_size); 
		header("Content-Disposition: attachment; filename=".$fileName); 
		$buffer		=	1024; 
		$file_count	=	0; 
		//向浏览器返回数据 
		while(!feof($fp) && $file_count < $file_size){ 
		$file_con	=	fread($fp,$buffer); 
		$file_count	+=	$buffer; 
		echo $file_con; 
		} 
		fclose($fp); 
	}
	
}
