<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取用户组列表
* $Id: Group_getList.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_Group_setPermit {
	/**
	 * 获取用户组列表
	 *
	 * @return  array $groupList
	 */
	function setPermit() {

		// uId
		$uId = MooObj::get('User')->verify();
		if (!$uId) {
			return false;
		}
		$user = MooObj::get('User')->getUser($uId);
		
		$userRole = $user->user_role;
		$userGames =  $user->user_games;
		$gameArr =explode(',', $userGames);
		
		$name = MooSession::get('name');
		$uId = MooSession::get('uId');
		
		MooView::set('selectGames', $gameArr);		// 所属游戏权限	
		MooView::set('userRole', $userRole);		// 角色权限
		
		$nowGame = MooConfig::get('main.defaultGame');
		MooView::set('nowGame', $nowGame);		// 默认游戏
		
		MooView::set('name', $name);		
		MooView::set('uId', $uId);
		
		$actionUrls = MooConfig::get('actionlog');
		if($actionUrls) {
			MooView::set('actionlogUrl', $actionUrls);
		}
		
		// 返回列表
		return $group;
	}
}