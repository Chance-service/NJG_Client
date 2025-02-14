<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取用户的相关权限
* $Id: User_getPermission.php 351 2013-05-10 14:00:43Z lulu $
*/

class User_getPermission {
	/**
	* 获取用户的相关权限
	 * @param  $uId  用户id
	 * @return  array $permission 用户的相关权限
	 *
	 */
	function getPermission() {
	// 获取用户id
		$uId = MooObj::get('User')->verify();
		
		// 用户
		$user = MooObj::get('User')->getUser($uId);
		
//		$group =  MooDao::get('Permit')->load($user->user_permission);	
//		// 权限
//		$groupPermission = json_decode($group->cp_permission, true);

		return $groupPermission;
	}
}