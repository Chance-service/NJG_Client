<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑 用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_add {
	/**
	 * 增加/编辑 用户
	 *
	 */
	function add($loginName, $password, $name, $groupId) {
		
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		// user dao
		$userDao =  MooDao::get('User');
		$user = $userDao->load(array('user_name'=>$loginName));
			
		// 已经存在   即为编辑
		if ($user) {
			if ($password != "******") {
				$user->set('user_password', md5($password));
			}
			$user->set('user_realName', $name);
			$user->set('group_id', $groupId);
			
			$res['msg'] = "更新成功";
			$res['code'] = 1;
			echo MooJson::encode($res);	
			exit;
		}

		// 插入
		$password = md5($password);
		$userDao->setData('user_name', $loginName);
		$userDao->setData('user_password', $password);
		$userDao->setData('user_realName', $name);	// 用户姓名
		$userDao->setData('group_id', $groupId);
		if(!$userDao->insert()) {
			$res['msg'] = "添加数据失败！";
			$res['code'] = 0;
			echo MooJson::encode($res);	
			exit;
		}

		return true;
	}
}