<?php
class Game_getGameList {

	function getGameList() {
		
		$returnData = array();
		
		$gameDao = MooDao::get('Game');
		$sql = "SELECT * FROM @TABLE ORDER BY  `game_time` DESC ";
		$gameList = $gameDao->getAll($sql);
		if (!$gameList) {
			return $returnData;
		}

		foreach ($gameList as $info) {
			$tmp = array();
			$tmp['id'] = $info['game_id'];
			$tmp['name'] = $info['game_name'];
			$tmp['tag'] = $info['game_tag'];
			$returnData[$tmp['id']] = $tmp;
		}

		return $returnData;
	}
}