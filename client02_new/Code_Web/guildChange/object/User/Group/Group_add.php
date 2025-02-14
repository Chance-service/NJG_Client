<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑 用户组
* $Id: Group_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_Group_add {
	/**
	 * 增加/编辑 用户组
	 *
	 * @param  $groupName  用户组名称
	 * @param  $groupAdmin 管理员
	 * @param  $groupBeta  发布beta
	 * @param  $groupRelease 发布release
	 * @param  $groupPmaRead pma读
	 * @param  $groupPmaWrite pma写
	 * @param  $groupWebLog 日志
	 * @param  $groupApp  平台权限
	 * @param  $groupEditName  需要编辑的用户组蜜罐子
	 * @param  $groupEditAdmin  需要编辑的管理权限
	 * @param  $groupEditBeta  需要编辑的用户组发布beta权限
	 * @param  $groupEditRelease  需要编辑的用户组发布release权限
	 * @param  $groupEditPmaRead  需要编辑的pma读权限
	 * @param  $groupEditPmaWrite  需要编辑的用户组pma写权限
	 * @param  $groupEditWebLog  需要编辑的用户的webLog权限
	 * @param  $groupEditApp  需要编辑的用户的平台权限
	 * @return  boolean
	 */
	function add($groupName = '', $groupAdmin = '', $groupBeta = '', $groupRelease = '', $groupPmaRead = '', $groupPmaWrite = '', $groupWebLog = '', $groupApp ='', $groupEditName = '', $groupEditAdmin = '', $groupEditBeta = '', $groupEditRelease = '', $groupEditPmaRead = '',  $groupEditPmaWrite = '',  $groupEditWebLog = '', $groupEditApp = '') {

		// 编辑已有的列表
		if (!$groupName && !$groupEditName) {
				$this->OBJ->setMsg('group.groupName.null');
				return false;
		}

		// group dao
		$groupDao =  MooDao::get('Group');

		// 循环更新
		foreach ((array)$groupEditName as $groupId=>$editName) {
			$editGroup = $groupDao->load($groupId);
			
			if ($editGroup) {
				// Name留空标识删除，否则更新
				if (!$groupEditName[$groupId]) {
					$editGroup->delete();
				} else {
					// 已有数据处理
					$groupPermission = array();
					// 管理权限
					$groupPermission['admin'] = $groupEditAdmin[$groupId];

					// 发布权限
					$groupPermission['publish'] = array($groupEditBeta[$groupId], $groupEditRelease[$groupId]);

					// pma权限
					$groupPermission['pma'] = array($groupEditPmaRead[$groupId], $groupEditPmaWrite[$groupId]);

					// 日志webLog权限
					$groupPermission['webLog'] = $groupEditWebLog[$groupId];

					// 应用列表
					$groupPermission['appList'] = $groupEditApp[$groupId];

					$groupPermissionSerialize = serialize($groupPermission);
					$editGroup->set('group_name', $groupEditName[$groupId]);
					$editGroup->set('group_permission', $groupPermissionSerialize);
				}
			}
		}


		// 新增
		if ($groupName) {

			$group = $groupDao->load(array('group_name'=>$groupName));

			// 已经存在
			if ($group) {
				$this->OBJ->setMsg('group.name.exists');
				return false;
			}

			// 插入用户组权限
			$groupPermission = array();
			// 管理平台权限
			$groupPermission['admin'] = $groupAdmin;

			// 发布权限
			$groupPermission['publish'] = array($groupBeta, $groupRelease);

			// pma权限
			$groupPermission['pma'] = array($groupPmaRead, $groupPmaWrite);

			// 日志webLog权限
			$groupPermission['webLog'] = $groupWebLog;

			// 应用列表
			$groupPermission['appList'] = $groupApp;

			$groupPermissionSerialize = serialize($groupPermission);
			$groupDao->setData('group_name', $groupName);
			$groupDao->setData('group_permission', $groupPermissionSerialize);
			$groupDao->insert();

		}

		return true;
	}
}