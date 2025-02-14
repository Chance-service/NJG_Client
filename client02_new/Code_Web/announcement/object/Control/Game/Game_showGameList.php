<?php
class Control_Game_showGameList {

	function showGameList() {
		$gameDao = MooDao::get('Game');
		$gameList = $gameDao->getAll('select * from @TABLE');
		if ($gameList) {
			MooView::set('gameList', $gameList);
		}
		MooView::render('gameList');
	}
}