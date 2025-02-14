<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_delete {
	/**
	 * 删除用户
	 *
	 */
	function delete() {
/*		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
*/
		// 如果有提交  则会收到 添加用户 的用户名
		$uId = MooForm::request('user_id');
		$dao = MooDao::get('User');
		$rs = $dao->query('delete from @TABLE where user_id = :id', array('id' => $uId));
		if ($rs) {
			$message = "删除成功";
		} else {
			$message = "删除失败";
		}
	
		MooView::set('msg', $message);
		MooObj::get('Control_User')->manage();

	}
}