<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑 用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_reset {
	/**
	 * 增加/编辑 用户
	 *
	 * @param  $userName  新用户名字
	 * @param  $userPassword 用户密码
	 * @param  $userGroupId  用户组id
	 * @param  $userEditName  需要编辑的用户名
	 * @param  $userEditPassword  需要编辑的密码
	 * @param  $userEditGroupId  需要编辑的用户组
	 * @return  boolean
	 */
	function reset() {
		
		// 获取用户信息
		$uId = MooForm::request('user_id');			// 用户名
		$user = MooDao::get('User')->load($uId);
		if (!$user) return false;
		$userName = $user->user_name;	// 用户名字
		MooObj::get('User')->setPermit();
		MooView::set('username', $userName);
		MooView::render('resetPassword');
		
	}
}