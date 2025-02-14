<?php
class Control_Recharge_fetchBills {

	function fetchBills() {
		
		$game 	= MooForm::request('game');
		$channel 	= MooForm::request('channel');
		$beginDate 	= MooForm::request('startTime');
		$endDate 	= MooForm::request('endTime');
		$type 	= MooForm::request('type');
		
		$fetchOrder = MooConfig::get('main.rechargeUrl.fetch_bills');
		
		if (!$game) {
			$startDate 	= 	date('Y-m-d', time());
			$endDate 	= 	date('Y-m-d', time());
			MooView::set('startDate', $startDate);
			MooView::set('endDate', $endDate);
			MooView::render('fetchBills2');
		} else {
			if($channel) {
				$url = $fetchOrder."?game=".$game."&channel=".$channel."&beginDate=".$beginDate."&endDate=".$endDate;
			} else {
				$url = $fetchOrder."?game=".$game."&beginDate=".$beginDate."&endDate=".$endDate;
			}

			MooObj::get('Control_Data')->setPlatformData($game);
			
			$rs = MooUtil::curl_send($url);
			$res = MooJson::decode($rs, true);
			
			if($res && $type == "daochu") {
				$excelData = array();
				
				$sDate = date("Ymd", strtotime($beginDate));
				$eDate = date("Ymd", strtotime($endDate));
				
				if ($channel) {
					$name = $game. "_" . $channel . "_"  . $sDate . "_" . $eDate;
				} else {
					$name = $game. "_" .  $sDate . "_" . $eDate;
				}
				
				$excelRs = array(
					0 => array(
						0 => '',
						1 => '',
						2 => '',
						3 => $name,
						4 => '',
						5 => '',
						6 => '',
					),
					1 => array(
						0 => '订单',
						1 => '渠道',
						2 => '所在服',
						3 => 'puid',
						4 => '充值金额',
						5 => '币种',
						6 => '充值时间',
				));
				
				foreach ($res as $key=>$val) {
					$arr[] = $val['orderid'];
					$arr[] = $val['platform'];
					$arr[] = $val['server'];
					$arr[] = $val['puid'];
					$arr[] = $val['pay'];
					$arr[] = $val['currency'];
					$arr[] = $val['time'];
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