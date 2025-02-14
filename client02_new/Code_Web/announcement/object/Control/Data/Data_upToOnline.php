<?php
class Control_Data_upToOnline {

	function upToOnline() {
		
		$fileName = MooForm::request('fileName');
		$game	 = MooForm::request('game');
		$selectArea = MooForm::request('selectArea');
		$selectLang = MooForm::request('selectLang');
		$dirPath = ROOT_PATH . "/notices/";
		$filePath = $dirPath . $fileName;
		$rs = MooFile::readAll($filePath);
		
		$data['game'] 		= $game;
		$data['area'] 		= $selectArea;
		$data['content'] 	= $rs;
		$urlConf = MooConfig::get('main.url');
		$url = $urlConf[$game][$selectArea];
		if($selectLang) {
			$data['lang'] 		= $selectLang;
			$url = $urlConf[$game][$selectArea][$selectLang];
		} else {
			$data['lang'] = "all";  // 非小语种全部都有
		}
		
		$res = MooUtil::curl_send($url, $data);
		
		if($res == "ok") {
			// 生效写入log
			$nowNotices = $dirPath . 'nowNotices.log';
			$r = MooFile::isExists($nowNotices);
			$tag = $game . "_" . $selectArea;
			if($selectLang) {
				$tag = $tag . "_" . $selectLang;
			}
			
			if(!$r) {
				// 不存在初次创建 写入文件
				$info[$tag] = $fileName;
				$infoJson = MooJson::encode($info);
				MooFile::write($nowNotices, $infoJson);
			} else {
				$info = MooFile::readAll($nowNotices);
				$infoArr = MooJson::decode($info, true);
				$infoArr[$tag] = $fileName;
				$infoJson = MooJson::encode($infoArr);
				MooFile::write($nowNotices, $infoJson);
			}
			
			$upToOnline = 1;
		} else {
			$upToOnline = 2;
		}
		MooUtil::redirect("index.php?mod=Data&do=selectNotices&game=" . $game . "&selectArea=" . $selectArea . "&selectLang=" . $selectLang . "&upToOnline=" . $upToOnline);
	}
}