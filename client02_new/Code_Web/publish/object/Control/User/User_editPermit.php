<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_editPermit {
	/*
	 * 管理用户权限
	 */
	function editPermit() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}

		$groupId = MooForm::request('groupId');
		
		$dao = MooDao::get('Group');
		$group = $dao->load($groupId);
		
		$permissionName = $group->group_name;
		$permissionJson = $group->group_permission;
		$permissionDesc = $group->group_dec;
		$permissionArr  = json_decode($permissionJson, true);
	
		// 修改与新增区别
		$editPermit	= 1;
		$manageUser 	= $permissionArr['manageUser'];
		$manageGame 	= $permissionArr['manageGame'];
		$manageServer 	= $permissionArr['manageServer'];
		$managePlatform = $permissionArr['managePlatform'];
		$openServer 	= $permissionArr['openServer'];
		$onlineCrontal 	= $permissionArr['onlineCrontal'];
		
		// 设置权限状态zhi
		MooView::set('groupId', $groupId);	
		MooView::set('groupName', $permissionName);
		MooView::set('groupDesc', $permissionDesc); // 备注
		
		MooView::set('editPermit', $editPermit);
		MooView::set('manageUser', $manageUser);
		MooView::set('manageGame', $manageGame);
		MooView::set('manageServer', $manageServer);
		MooView::set('managePlatform', $managePlatform);
		MooView::set('openServer', $openServer);
		MooView::set('onlineCrontal', $onlineCrontal);
		
		// array
		MooView::set('publish', $permissionArr['publish']);
		
		$serverIds = $permissionArr['serverIds'];
		$serverIdsArr = MooJson::decode($serverIds, true);
		// 是否是全局权限 all no
		MooView::set('serverIdsIsAll', $serverIdsArr['isAll']);
		// 如果不是全局权限 分配传递的sids数组
		if ($serverIdsArr['isAll'] == 'no') {
			MooView::set('sids', $serverIdsArr['ids']);
		}
		
		// 获取游戏ids
		$gameIds = MooObj::get('Publish')->getGameIds();
		foreach ($gameIds as $key => $gameId) {
			$treeDatas[$gameId] = MooObj::get('Publish')->getTreeDataByGameId($gameId);
		}			
		
		// treeDatas 包含多个游戏
		MooView::set('treeDatas', $treeDatas);		
		
		MooView::render('editPermit');
	}

}