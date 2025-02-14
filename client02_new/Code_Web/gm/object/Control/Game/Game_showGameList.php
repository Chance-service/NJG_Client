<?php
class Control_Game_showGameList {

	function showGameList() {

		$url = MooConfig::get('main.url.fetch_game');
		$res = MooUtil::curl_send($url);
		
		$gameList = MooJson::decode($res, true);		
		if ($gameList) {
			MooView::set('gameList', $gameList);
		}
		
		MooView::render('gameList');
	}
}