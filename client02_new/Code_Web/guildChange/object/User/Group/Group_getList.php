<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取用户组列表
* $Id: Group_getList.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_Group_getList {
	/**
	 * 获取用户组列表
	 *
	 * @return  array $groupList
	 */
	function getList() {

		static $groupList = array();

		if ($groupList) {
			return $groupList;
		}

		$groupDao =  MooDao::get('Permit');
		$getGroupList = $groupDao->getAll("SELECT * FROM @TABLE WHERE 1");
		
		
		if (!$getGroupList) {
			$groupList = $getGroupList;
			return false;
		}

		// 重新处理列表
		foreach($getGroupList as $key=>$group) {
			$groupList[$group['cp_id']] = $group;
		}
		
		// 返回列表
		return $groupList;

	}
}