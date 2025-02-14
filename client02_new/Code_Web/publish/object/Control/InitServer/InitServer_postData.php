<?php
class Control_InitServer_postData {

	function postData() {
		
		$serverList = MooForm::request('serverList');
		$gameId = MooForm::request('gameId');
		if ($gameId && $serverList) {
			$pubLog = MooObj::get('InitServer_Log')->getExecDetail($gameId, $serverList);
		} else {
			$pubLog['isPublishIng'] = 1;
			$pubLog['log'] = '初始化服务器 ing ...';
		}
		
		if ($gameId) {
			$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
			MooView::set('gameName', $gameInfo['gameName']);
		}
		
		MooView::set('pubLog', $pubLog);
		MooView::render('initServerView');
	}
}