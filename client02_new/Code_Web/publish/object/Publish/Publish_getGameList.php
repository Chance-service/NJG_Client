<?php
class Publish_getGameList {

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
			$tmp['svnChechout'] = $info['game_checkout_url'];
			$tmp['svnUserName'] = $info['game_svn_user_name'];
			$tmp['svnPassword'] = $info['game_svn_password'];
			$returnData[$tmp['id']] = $tmp;
		}

		return $returnData;
	}
}