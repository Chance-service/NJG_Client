<?php
class Publish_addGame {

	function addGame() {

		$gameTag = MooForm::request('gameTag');
		$gameName = MooForm::request('gameName');
		
		$gameDao = MooDao::get('Game');
		$gameObj = $gameDao->load(array('game_tag' => $gameTag));
		if ($gameObj) {
			return false;
		}
		
		$gameDao->setData('game_tag', $gameTag);
		$gameDao->setData('game_name', $gameName);
		$gameDao->setData('game_time', time());
		$gameDao->insert();

		return true;
	}
}