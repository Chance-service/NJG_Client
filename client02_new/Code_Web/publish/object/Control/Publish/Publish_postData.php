<?php
class Control_Publish_postData {

	function postData() {
		
		$serverList = MooForm::request('serverList');
		$gameId = MooForm::request('gameId');
		if ($gameId && $serverList) {
			$pubLog = MooObj::get('Publish_Log')->getExecDetail($gameId, $serverList);
		} else {
			$pubLog['isPublishIng'] = 1;
			$pubLog['log'] = '发布 ing ...';
		}
		
		if ($gameId) {
			$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
			MooView::set('gameName', $gameInfo['gameName']);
		}
		
		MooView::set('pubLog', $pubLog);
		MooView::render('publishView');
	}
}