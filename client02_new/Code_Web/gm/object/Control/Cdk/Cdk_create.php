<?php
class Control_Cdk_create {

	function create() {
		
		$game = MooForm::request('game');
		if (!$game) {
			MooView::render('createCdk');
		} else {
			$platform = MooForm::request('channel');
			$cdkType = MooForm::request('cdkType');
			$giftContent = MooForm::request('giftContent');
			$cdkNum = MooForm::request('cdkNum');
			
			$starttime = MooForm::request('startTime');
			$endtime = MooForm::request('endTime');
			
			if($starttime) {
				$starttime = date('Ymd', strtotime($starttime)) . "000000";
			} else {
				$starttime = "";
			}
			if($endtime) {
				$endtime = date('Ymd', strtotime($endtime)) . "000000";
			} else {
				$endtime = "";
			}
			
			$cdkUrl = MooConfig::get('main.cdkUrl');
			if ($platform) {
				$createCdkUrl = $cdkUrl . "/" . "gen_cdk?" . "game=" . $game . "&platform=" . $platform . "&type=" . $cdkType . "&count=" . $cdkNum . "&reward=" . $giftContent . "&starttime=" . $starttime  . "&endtime=" . $endtime; 
			} else {
				$createCdkUrl = $cdkUrl . "/" . "gen_cdk?" . "game=" . $game  . "&type=" . $cdkType . "&count=" . $cdkNum . "&reward=" . $giftContent . "&starttime=" . $starttime  . "&endtime=" . $endtime; 
			}

			$res = MooUtil::curl_send($createCdkUrl);
			
//			$result = '{"status":"0","type":"game=lz&platform=91&type=ta&reward=11001_1001_66&createtime=20150227152823&starttime=20150101000000&endtime=20150201000000","cdks":["ollzetoa605hxshj","glqzhtxad5ag90cj","wl6z4tuays64c1em","2lvzit2a3o9k5xkc","2lqzxtea57g7av6y"]}';
			$result = MooJson::decode($res);
			if($result['status'] == 0) {
				// 生成成功
				$message = $result['type'];
				$createInfoArr = explode('&',$message); 
				$messArr = array();
				for($index = 0;$index < count($createInfoArr); $index++) { 
					 $info = $createInfoArr[$index];
					 $infoArr = explode('=',$info);
					 $messArr[$infoArr[0]] =  $infoArr[1];
				} 
				$cdks = array();
				if($result['cdks']) {
					foreach ($result['cdks'] as $key => $val) {
						$cdks[$key][] = $val;
					}
				}
				$writeExcelArr[0]['name'] = '生成cdks';
				$writeExcelArr[0]['data'] = $cdks;
				
				
				if ($messArr['platform']) {
					if ($messArr['starttime'] && $messArr['endtime']) {
						$cdkName =  $messArr['game'] . "_" . $messArr['platform'] . "_" . $messArr['type'] . "_" . $messArr['starttime'] . "_" . $messArr['endtime'] . ".xls";
					} else {
						$cdkName =  $messArr['game'] . "_" . $messArr['platform'] . "_" . $messArr['type'] . ".xls";
					}
					
				} else {
					if ($messArr['starttime'] && $messArr['endtime']) {
						$cdkName =  $messArr['game'] . "_" . $messArr['type'] .  "_" . $messArr['starttime'] . "_" . $messArr['endtime'] . ".xls";
					} else {
						$cdkName =  $messArr['game'] . "_" . $messArr['type'] . ".xls";
					}
					
				}
				
				$fileName  = ROOT_PATH . "/cdks/" . $cdkName;
				$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write($fileName, $writeExcelArr);
				if ($rs) {
					// 下载文件
			     	$this->downFile($fileName, $cdkName);
			   } else {
				   	MooView::set('errorMsg',"写入文件失败");
					MooView::render('createCdk');
			   }
			/*	
				MooView::set('game', $messArr['game']);
				MooView::set('platform', $messArr['platform']);
				MooView::set('type', $messArr['type']);
				MooView::set('reward', $messArr['reward']);
				MooView::set('createtime', $messArr['createtime']);
				MooView::set('starttime', $messArr['starttime']);
				MooView::set('endtime', $messArr['endtime']);
			*/	
				
			} else {
				$logPath = ROOT_PATH . "/log/createCdks.log." . date('Y-m-d');
				// 如果失败写入log
				MooFile::write($logPath, date('Y-m-d H:i:s') . "--" . $res . "\n", true);
				if ($result['status'] == 10) {
					$errMsg = "该cdk已经创建过,请直接追加!";
				}
				// 生成失败
				MooView::set('errorMsg',$errMsg);
				MooView::render('createCdk');
			}
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