<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑 用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_resetPassword {
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
	function resetPassword() {
		
		// 获取用户信息
		$userName = MooForm::request('username');			// 用户名
		$password = MooForm::request('password');			// 密码
		$repassword = MooForm::request('rePassword');		// 确认密码
		
		if ($password != $repassword) {
			$message = "两次输入的密码不一致，重新输入！";
			MooView::set('msg', $message);
			MooView::render('resetPassword');
			exit;
		}
		
		$user = MooDao::get('User')->load(array('user_name' => $userName));
		if (!$user) return false;
		
		$user->set('user_password', md5($password));
		$message = "修改成功";
		MooView::set('msg', $message);
		MooObj::get('User')->setPermit();
		MooView::render('resetPassword');
		
	}
}