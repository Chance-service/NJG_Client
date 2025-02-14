<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 获取用户组列表
* $Id: Group_getList.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_Group_getPublishPermitBygameId {
	/**
	 * 获取用户组列表
	 *
	 * @return  array $groupList
	 */
	function getPublishPermitBygameId($gameId) {
		// 获取玩家uId
	    $uId = MooObj::get('User')->verify();
	    $user = MooObj::get('User')->getUser($uId);
		$groupDao =  MooDao::get('Group');
		$groupObj = $groupDao->load($user->group_id);
		if (!$groupObj){
			return false;
		}
		// 获取权限 转数组
		$permit = array();
		$group = json_decode($groupObj->group_permission, true);
		// 发布权限
		if ($group['publish']) {
			$publishPermit = $group['publish'];
			if ($publishPermit[$gameId]['beta'] && $publishPermit[$gameId]['beta'] == 1){
				
				$permit['beta'] = 1;
			} else {
				$permit['beta'] = 0;
			}		
	
				// release
			if ($publishPermit[$gameId]['release'] && $publishPermit[$gameId]['release'] == 1){
				$permit['release'] = 1;
			} else {
				$permit['release'] = 0;
				}
		} else {
			$permit['beta'] = 0;
			$permit['release'] = 0;
		}

		// 返回列表
		
		return $permit;
	}
}