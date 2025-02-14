<?php
class Control_Game_delGame {

	function delGame() {
		$gameId	= MooForm::request('gameId');
		$gameDao = MooDao::get('Game');
		
		$rs = $gameDao->query('delete from @TABLE where game_id = :id', array('id' => $gameId));
		
		if ($rs) {
			$message = "删除成功";
		} else {
			$message = "删除失败";
		}
		
		$returnData['code'] = 1;
		$returnData['msg'] = $message;
		exit(MooJson::encode($returnData));
	}
}