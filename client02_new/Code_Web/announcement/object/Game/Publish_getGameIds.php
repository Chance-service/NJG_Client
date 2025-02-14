<?php
class Publish_getGameIds {

	function getGameIds() {
		
		$gameIds = array();
		$gameDao = MooDao::get('Game');
		$gameIds = $gameDao->getCol('select game_id from @TABLE');
		
		return $gameIds;
	}
}