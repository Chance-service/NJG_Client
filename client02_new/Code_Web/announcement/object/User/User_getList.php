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

		 $userList = array();

		$userDao =  MooDao::get('User');

		$getUserList = $userDao->getAll("SELECT * FROM @TABLE WHERE 1");

		if (!$getUserList) {
			return $userList;
		}
		
		// 返回列表
		return $getUserList;

	}
}