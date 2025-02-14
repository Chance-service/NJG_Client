<?php
class Publish_getGameInfo {

	function getGameInfo($gameId) {
		
		$returnData = array();
		
		$gameDao = MooDao::get('Game');
		$gameObj = $gameDao->load($gameId);
		if (!$gameObj) {
			return false;
		}
		
		$returnData['gameTag'] = $gameObj->game_tag;
		$returnData['gameName'] = $gameObj->game_name;
		$returnData['checkoutUrl'] = $gameObj->game_checkout_url;
		$returnData['svnUserName'] = $gameObj->game_svn_user_name;
		$returnData['svnPassword'] = $gameObj->game_svn_password;

		return $returnData;
	}
}