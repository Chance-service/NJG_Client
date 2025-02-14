<?php
class Control_Game_addGame {

	function addGame() {
		
		$type	= MooForm::request('type');
		$gameId	= MooForm::request('gameId');
		
		$gameName 	= MooForm::request('gameName');
		$gameTag 	= MooForm::request('gameTag');
		$gameArea 	= MooForm::request('gameArea');
		$gameLang	= MooForm::request('gameLang');
		
		if (!$gameName) {
			MooView::render('addGame');
		} else {
			if($gameId && $type && $type == "save") {
				$game = MooDao::get('Game')->load($gameId);
				$game->set('game_name', $gameName);
				$game->set('game_tag', $gameTag);
				$game->set('game_Area', $gameArea);
				if($gameLang) {
					$game->set('game_Lang', $gameLang);
				}
				
				$returnData['code'] = 1;
				$returnData['msg'] = '保存成功';
				exit(MooJson::encode($returnData));
				
			} else {
				$gameDao = MooDao::get('Game');
				$gameDao->setData('game_tag', $gameTag);
				$gameDao->setData('game_name', $gameName);
				$gameDao->setData('game_Area', $gameArea);
				if ($gameLang) {
					$gameDao->setData('game_Lang', $gameLang);
				}
				if($gameDao->insert()) {
					$returnData['code'] = 0;
					$returnData['msg'] = '添加成功';
					exit(MooJson::encode($returnData));
				} else {
					$returnData['code'] = 1;
					$returnData['msg'] = '添加失败';
					exit(MooJson::encode($returnData));
				}
			}
		}
	}
}