<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_manage {
	/**
	 * 用户添加用户
	 *
	 */
	function manage() {

		$addSubmit = MooForm::request('addSubmit');

		if($addSubmit) {

			$userName = MooForm::request('userName');
			$userPassword = MooForm::request('userPassword');
			$userGroupId = MooForm::request('userGroupId');
			$userEditName = MooForm::request('userEditName');
			$userEditPassword = MooForm::request('userEditPassword');
			$userEditGroupId = MooForm::request('userEditGroupId');

			$add = MooObj::get('User')->add($userName, $userPassword, $userGroupId, $userEditName, $userEditPassword, $userEditGroupId);
			if (!$add) {
				$message = $this->OBJ->getMsg();
				$message = $message[0];
			} else {
				$message = '增加/编辑用户成功';
			}

			MooObj::get('Control')->showMessage($message, 'index.php?mod=User&do=add');
		} else {
		
			// 用户列表
			$userList = MooObj::get('User')->getList();
			
			if($userList) {
				foreach ($userList as $key => $val) {
					if ($val['user_role'] == 0) {
						$userList[$key]['user_role'] = "普通用户";
					} elseif($val['user_role'] == 1) {
						$userList[$key]['user_role'] = "管理员";
					}
					$userList[$key]['create_time'] = date('Y-m-d H:i:s',$userList[$key]['create_time']);
				}
			}
			
			MooView::set('userList', $userList);
			MooView::render('manageUser');
		}

	}

}