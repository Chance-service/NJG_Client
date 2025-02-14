<?php
class Control_Data_edit {

	function edit() {
		$nowGame = MooForm::request('game');
		$selectArea = MooForm::request('selectArea');
		$selectLang = MooForm::request('selectLang');
		$fileName = MooForm::request('fileName');
		
		if($selectLang || $selectArea == "r2") {
			$gameInfo = MooDao::get('Game')->load(array('game_tag' => $nowGame));
			$langInfo = $gameInfo->game_lang;
			if($langInfo) {
				$langInfoArr = explode('_', $langInfo);
				$langs[$langInfoArr[0]] = $langInfoArr[1];
				$langConf = explode("," , $langs[$selectArea]);
				
				MooView::set('viewLang', 1);  // 语种显示
				MooView::set('channels', $langConf);
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
		
		$filePath = ROOT_PATH . "/notices/" . $fileName;
		$content  = MooFile::readAll($filePath);
		
		$content = str_replace("'", "|", $content);
		//echo $content;
		
		MooView::set('nowGame', $nowGame);
		MooView::set('nowPlatform', $selectArea);
		MooView::set('nowLang', $selectLang);
		MooView::set('fileName', $fileName);
		MooView::set('type', 2);  // 编辑
		MooView::set('content', $content);
		
		MooView::render('editAnnounce');
	}
}