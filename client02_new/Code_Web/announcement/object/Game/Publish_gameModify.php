<?php
class Publish_gameModify {

	function gameModify() {
	
		$gameId = MooForm::request('gameId');
		$type = MooForm::request('type');
		$gameTag = MooForm::request('gameTag');
		$gameName = MooForm::request('gameName');
		
		$gameDao = MooDao::get('Game');
		$gameObj = $gameDao->load($gameId);
		if (!$gameObj) {
			return false;
		}
		if ($type == 'del') {
			$gameObj->delete();
		} else {
			$gameObj->set('game_tag', $gameTag);
			$gameObj->set('game_name', $gameName);
		}

		return true;
	}
}