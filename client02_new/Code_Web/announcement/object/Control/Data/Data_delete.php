<?php
class Control_Data_delete {

	function delete() {
		
		$fileName = MooForm::request('fileName');
		$game	 = MooForm::request('game');
		$selectArea = MooForm::request('selectArea');
		$selectLang = MooForm::request('selectLang');
		$dirPath = ROOT_PATH . "/notices/";
		$filePath = $dirPath . $fileName;
		$rs = MooFile::rm($filePath);
		
		MooUtil::redirect("index.php?mod=Data&do=selectNotices&game=" . $game . "&selectArea=" . $selectArea . "&selectLang=" . $selectLang);
	/*	
		$nowGame = MooConfig::get('main.nowGame');
		$gameInfo = MooDao::get('Game')->load(array('game_tag' => $nowGame));
		
		// 用户id
		$uId = MooObj::get('User')->verify();
		$user = MooDao::get('User')->load($uId);
		$myAreaInfo = $user->user_areas;
		$areaArrs = explode('|', $myAreaInfo);
		
		if($areaArrs[0]) {
			$areaInfoArr = explode(',',$areaArrs[0]);
			MooView::set('areaInfoArr', $areaInfoArr);
		}
		
		MooView::set('nowGame', $nowGame);
		MooView::render('notices');
		*/
	}
}