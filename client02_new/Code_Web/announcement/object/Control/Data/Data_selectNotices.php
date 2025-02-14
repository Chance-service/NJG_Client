<?php
class Control_Data_selectNotices {

	function selectNotices() {
		
		$nowGame = MooForm::request('game');
		$selectArea = MooForm::request('selectArea');
		$selectLang = MooForm::request('selectLang');
		
		if($selectLang || $selectArea == "r2") {
			$gameInfo = MooDao::get('Game')->load(array('game_tag' => $nowGame));
			$langInfo = $gameInfo->game_lang;
			if($langInfo) {
				$langInfoArr = explode('_', $langInfo);
				$langs[$langInfoArr[0]] = $langInfoArr[1];
				$langConf = explode("," , $langs[$selectArea]);
				
				MooView::set('viewLang', 1);  // 语种显示
				MooView::set('nowLang', $selectLang);
				MooView::set('channels', $langConf);
			}
		}
		//index.php?mod=Game&do=getLangByAreaGame&game="+game+"&areaName="+areaName
		
		$upToOnline = MooForm::request('upToOnline');
		$gameInfo = MooDao::get('Game')->load(array('game_tag' => $nowGame));
		
		$dirPath = ROOT_PATH . "/notices/";
		$fileList = MooFile::getFileList($dirPath);
		$tag = $nowGame . "_" . $selectArea;
		if($selectLang) {
			$tag = $tag . "_" . $selectLang;
		}
		
		$nowNotices = $dirPath . 'nowNotices.log';
		$exist = MooFile::isExists($nowNotices);
		if ($exist) {
			$info = MooFile::readAll($nowNotices);
			$infoArr = MooJson::decode($info, true);
		}
		
		$files = array();
		if($fileList) {
			foreach ($fileList as $key => $val) {
				if (strpos($val, $tag) === 0) {
					$file['gameName'] = $nowGame;
					$file['selectArea'] = $selectArea;
					$file['selectLang'] = $selectLang;
					$file['fileName'] = $val;
					
					$preName = $nowGame . "_" . $selectArea;
					if($selectLang) {
						$preName = $preName . "_" . $selectLang;
					}
					
					if($infoArr && $infoArr[$preName] && $infoArr[$preName] == $val) {
						// 在线上
						$file['isOnline'] = 1;
					} else {
						$file['isOnline'] = 0;
					}
					
					$files[] = $file;
				}
			}
		}
		
		// 用户id
		$uId = MooObj::get('User')->verify();
		$user = MooDao::get('User')->load($uId);
		$myAreaInfo = $user->user_areas;
		$areaArrs = explode('|', $myAreaInfo);
		
		if($areaArrs[0]) {
			$areaInfoArr = explode(',',$areaArrs[0]);
			MooView::set('areaInfoArr', $areaInfoArr);
		}
		
		MooView::set('filList', $files);
		MooView::set('nowGame', $nowGame);
		MooView::set('selectArea', $selectArea);
		MooView::set('selectLang', $selectLang);
		if($upToOnline && $upToOnline == 1) {
			MooView::set('upToOnline', $upToOnline);
		}
		
		MooView::render('notices');
	}
}