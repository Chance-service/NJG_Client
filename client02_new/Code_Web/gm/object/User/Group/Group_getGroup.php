<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取用户组列表
* $Id: Group_getList.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_Group_getGroup {
	/**
	 * 获取用户组列表
	 *
	 * @return  array $groupList
	 */
	function getGroup($groupId) {

		if (!$groupId) {
			return false;
		}	
		$groupDao =  MooDao::get('Group');
		$groupObj = $groupDao->load($groupId);
		if (!$groupObj){
			return false;
		}
		// 获取权限 转数组
		$group = json_decode($groupObj->group_permission);
		
		// 返回列表
		return $group;
	}
}