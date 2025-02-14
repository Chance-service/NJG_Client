<?php
class Control_ServerOnOff_postData {

	function postData() {
		
		$serverList = MooForm::request('serverList');

	/*	
		$endStr = substr($serverList,strlen($serverList)-3, strlen($serverList));
		if ($endStr == 128 || $endStr == 130) {
			$serverList = substr($serverList,0, strlen($serverList) - 4);
		}
	*/	
		
		$gameId = MooForm::request('gameId');
		$type = MooForm::request('type');
		if ($gameId && $serverList && $type) {
			$pubLog = MooObj::get('ServerOnOff_Log')->getExecDetail($gameId, $serverList, $type);
		} else {
			$pubLog['isPublishIng'] = 1;
			if ($type == 'on') {
				$pubLog['log'] = '开服 ing ...';
			} elseif ($type == 'off') {
				$pubLog['log'] = '停服 ing ...';
			} else {
				$pubLog['log'] = '无缝重启服 ing ...';
			}
		}
		
		if ($gameId) {
			$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
			MooView::set('gameName', $gameInfo['gameName']);
		}
		
		MooView::set('type', $type);
		MooView::set('pubLog', $pubLog);
		MooView::render('serverOnOffView');
	}
}