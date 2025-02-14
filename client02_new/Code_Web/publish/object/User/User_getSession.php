<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 取得当前登录用户相关信息
* $Id: User_getSession.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_getSession {
	/**
	 * 取得当前登录用户相关信息
	 *
	 * @return  array()
	 */
	function getSession() {

		// 用户基本信息， 拥有权限的应用列表，管理权限
		static $session = array(
			'user'=> array(),
			'appList'=>array(),
			'permission'=>array(),
		);

		// 防止多次调用
		if ($session['user']['user_id']) {
			return $session;
		}

		// 未登录状态
		$uId = MooObj::get('User')->verify();
		if (!$uId) {
			return $session;
		}

		// 用户信息
		$user = MooObj::get('User')->getUser($uId);

		// 用户基本信息
		$session['user'] = $user->getData();

		// 拥有权限的应用列表
		$appList = MooObj::get('User')->getAppList($uId);
		$session['appList'] = $appList;

		// 是否是管理员
		$permission = MooObj::get('User')->getPermission($uId);
		$session['permission'] = $permission;

		return $session;
	}
}