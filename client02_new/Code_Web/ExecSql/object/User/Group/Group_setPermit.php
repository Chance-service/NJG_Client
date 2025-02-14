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

		$groupDao =  MooDao::get('Group');
		$groupObj = $groupDao->load($user->group_id);
		// 获取权限 转数组
		if ($groupObj) {
			$group = json_decode($groupObj->group_permission, true);
			MooView::set('mangerUser', $group['manageUser']);
			MooView::set('manageGame', $group['manageGame']);
			MooView::set('manageServer', $group['manageServer']);	
			MooView::set('managePlatform', $group['managePlatform']);
			MooView::set('openServer', $group['openServer']);		
			MooView::set('publish', $group['publish']);
		}
		
		$name = MooSession::get('name');
		$uId = MooSession::get('uId');
		MooView::set('name', $name);		
		MooView::set('uId', $uId);
		
		$gameList = MooObj::get('Publish')->getGameList();		
		MooView::set('game', $gameList);		
		// 返回列表
		return $group;
	}
}