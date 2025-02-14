<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取列表
* $Id: User_getList.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_getList {
	/**
	 * 获取列表
	 *
	 * @return  array $userList
	 */
	function getList() {

		static $userList = array();

		if ($userList) {
			return $userList;
		}

		$userDao =  MooDao::get('User');

		$getUserList = $userDao->getAll("SELECT * FROM @TABLE WHERE 1");

		if (!$getUserList) {
			$userList = $getUserList ;
			return false;
		}

		// 重新处理列表
		foreach($getUserList as $key=>$user) {
			$groupObj	= MooDao::get('Group')->load($user['group_id']);
			$user['groupName'] = $groupObj->group_name;
			$userList[$user['user_id']] = $user;
		}
	
		// 返回列表
		return $userList;

	}
}