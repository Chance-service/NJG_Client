<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 用户组的编辑/增加
* $Id: Group_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_Group_delete {
	/**
	 * 用户组的删除
	 */
	function delete() {
			// 判断权限
			$permission	= MooObj::get('User')->getPermission();
			// 没有用户管理权限
			if($permission['manageUser'] != 1) {
				$message = "你没有操作权限!";
				MooView::set('msg', $message);
				MooView::render('permitError');
			}
			
			$group_id = MooForm::request('group_id');
			if (!$group_id) {
				return false;
			}
			$dao = MooDao::get('Group');		
			$rs = $dao->query('delete from @TABLE where group_id = :gId', array('gId' => $group_id));

			if ($rs) {
				$message = "删除成功";
				MooView::set('msg', $message);
				MooObj::get('Control_User')->mangePermit();
			}
	}
}