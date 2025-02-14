<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_add {
	/**
	 * 增加/编辑用户
	 *
	 * @param  $request['userName']  用户名
	 * @param  $request['userPassword']  用户密码
	 * @param  $request['userGroupId'] 用户组id
	 * @param  $request['userEditName']  需要编辑的用户名
	 * @param  $request['userEditPassword']  需要编辑的密码
	 * @param  $request['userEditGroupId']  需要编辑的用户组
	 * @param  $request['addSubmit']  是否为提交
	 * @return  void
	 */
	function add() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		
		// 如果有提交  则会收到 添加用户 的用户名
		$loginName = MooForm::request('loginName');			// 用户名
		if($loginName) {
			$password 	= MooForm::request('password');		// 密码
			$name 		= MooForm::request('name');			// 用户姓名
			$groupId	= MooForm::request('groupId');		// 用户组id
			
			$add = MooObj::get('User')->add($loginName, $password, $name, $groupId);
			$res = array();
			if (!$add) {
				$res['msg'] = "添加失败";
				$res['code'] = 0;
			} else {
				$res['msg'] = "添加成功";
				$res['code'] = 1;
			}
			
			echo MooJson::encode($res);	
			exit;
		} else {

		// 用户组列表
			$groupList = MooObj::get('User_Group')->getList();
			MooView::set('groupList', $groupList);
				
			MooView::render('addUser');
		}

	}

}