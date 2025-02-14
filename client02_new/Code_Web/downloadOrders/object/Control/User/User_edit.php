<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_edit {
	/**
	 * 编辑用户
	 */
	function edit() {
		// 如果有提交  则会收到 添加用户 的用户名
		$uId = MooForm::request('user_id');
		$user = MooDao::get('User')->load($uId);
		if (!$user) {
			$res['msg'] = "该用户不存在";
			$res['code'] = 0;
			echo MooJson::encode($res);	
			exit;
		}
		MooView::set('user_realName', $user->user_real_name);
		MooView::set('user_name', $user->user_name);
		MooView::set('role', $user->user_role);
		MooView::set('user_games', $user->user_games);
		
		$myGames = $user->user_games;
		
		/*
		$url = "http://182.254.230.39:9001/fetch_game";
		$res = MooUtil::curl_send($url);
		$gameList = MooJson::decode($res, true);
		*/
		
		$gameArr = MooConfig::get('main.game');
		$gameList[0]['game'] = $gameArr['0'];
		
		if($gameList) {
			foreach ($gameList as $key => $val) {
				if(strstr($myGames, $val['game'])) {
					$gameList[$key]['checked'] = 1;
				} else {
					$gameList[$key]['checked'] = 0;
				}
			}
		}
		
		if ($gameList) {
			MooView::set('game', $gameList);
		}
		
		MooView::render('editUser');
	}
}