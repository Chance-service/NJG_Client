<?php
class Control_Game_addGame {

	function addGame() {
		
		$game 		= MooForm::request('game');
		$platform 	= MooForm::request('platform');
		$channel 	= MooForm::request('channel');
		$logUserName = MooForm::request('logUserName');
		$logUserPwd = MooForm::request('logUserPwd');
		$logPath 	= MooForm::request('logPath');
		$sshPort 	= MooForm::request('sshPort');
		
		$createGameUrl = MooConfig::get('main.url.create_game');
		
		if (!$game) {
			MooView::render('addGame');
		} else {
			$url = $createGameUrl."?game=".$game."&platform=".$platform."&channel=".$channel."&logUserName=".$logUserName."&logUserPwd=".$logUserPwd."&logPath=".$logPath."&sshPort=".$sshPort;
			$rs = MooUtil::curl_send($url);

			$res = MooJson::decode($rs, true);
			if($res['status'] == 0) {
				$returnData['code'] = 0;
				$returnData['msg'] = '操作成功';
				exit(MooJson::encode($returnData));
			} else {
				$returnData['code'] = 1;
				$returnData['msg'] = '操作失败';
				exit(MooJson::encode($returnData));
			}
		}
	}
}