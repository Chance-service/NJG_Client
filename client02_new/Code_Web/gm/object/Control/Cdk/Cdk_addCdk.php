<?php
class Control_Cdk_addCdk {
	function addCdk() {
		$game = MooForm::request('game');
		$platform = MooForm::request('channel');
		$cdkType = MooForm::request('cdkType');
		$cdkNum = MooForm::request('cdkNum');
		$cdkUrl = MooConfig::get('main.cdkUrl');
		if ($platform) {
			$addCdkUrl = $cdkUrl . "/" . "append_cdk?" . "game=" . $game . "&platform=" . $platform . "&type=" . $cdkType . "&count=" . $cdkNum; 
		} else {
			$addCdkUrl = $cdkUrl . "/" . "append_cdk?" . "game=" . $game  . "&type=" . $cdkType . "&count=" . $cdkNum; 
		}

		$res = MooUtil::curl_send($addCdkUrl);
		// 记录addCdk log 
	/*	$logPath = ROOT_PATH . "/log/addCdks.log." . date('Y-m-d');
		MooFile::write($logPath, date('Y-m-d H:i:s') . "--url--" . $addCdkUrl . "/n--res:" . $res . "/n", true);
	*/
	//  $res = '{"status":"0","type":"game=lz&platform=uc&type=tb&reward=11001_1001_10&createtime=20150228103640&starttime=20150226000000&endtime=20150328000000","cdks":["clkzqt0b24hjc5qa","il1zjt0bwnh907vd","8lezptob8zm7z7dy","slmzstqbyk1k06hq","bllzzt0br7z8y87p","clxztt6bf17go4x4","2lvzktqb7e4eb8cp","uloz7tlbvm2q982l","9lhz1tgbth7v14yc","vlgzztmb78oz5o2w"]}';
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
			$writeExcelArr[0]['name'] = '追加cdks';
			$writeExcelArr[0]['data'] = $cdks;
			
			if ($messArr['platform']) {
				$cdkName =  $messArr['game'] . "_" . $messArr['platform'] . "_" . $messArr['type'] . "_" . $messArr['starttime'] . "_" . $messArr['endtime'] . ".xls";
			} else {
				$cdkName =  $messArr['game'] . "_" . $messArr['type'] .  "_" . $messArr['starttime'] . "_" . $messArr['endtime'] . ".xls";
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
			
		} else {
			$logPath = ROOT_PATH . "/log/addCdks.log." . date('Y-m-d');
			// 如果失败写入log
			MooFile::write($logPath, date('Y-m-d H:i:s') . "--" . $res . "\n", true);
			
			$errMsg = "追加cdk失败!";
			// 生成失败
			MooView::set('errorMsg',$errMsg);
			MooView::render('createCdk');
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