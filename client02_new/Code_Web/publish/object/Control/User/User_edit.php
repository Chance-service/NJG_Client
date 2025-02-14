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
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		// 如果有提交  则会收到 添加用户 的用户名
		$uId = MooForm::request('user_id');
		$user = MooDao::get('User')->load($uId);
		if (!$user) {
			$res['msg'] = "该用户不存在";
			$res['code'] = 0;
			echo MooJson::encode($res);	
			exit;
		}
		
		// 用户组
		$groupList = MooObj::get('User_Group')->getList();
		MooView::set('groupList', $groupList);
		
		MooView::set('user_name', $user->user_name);
		MooView::set('user_realName', $user->user_realName);
		
		$group = array(0 => array('gId' => $user->group_id));
		MooView::set('group', $group);
		MooView::render('editUser');

	}
}