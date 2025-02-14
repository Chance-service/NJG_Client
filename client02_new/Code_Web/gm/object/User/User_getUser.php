<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 取得用户信息
* $Id: User_getUser.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_getUser {
	/**
	 * 取得用户信息
	 *
	 * @param  $uId  用户的uid/用户名
	 * @param  $getType  获取用户方式
	 * @return   用户对象
	 */
	function getUser($uId, $getType = 'user_id') {

		if (!$uId) {
			$this->OBJ->setMsg('user.user.noUid');
			return false;
		}
		if ($getType == 'user_id') {
			// 通过用户id方式获得用户信息
			$user = MooDao::get('User')->load($uId);
		} else {
			// 通过用户名方式获得用户信息
			$user = MooDao::get('User')->load(array('user_name'=>$uId));
		}

		return $user;
	}
}