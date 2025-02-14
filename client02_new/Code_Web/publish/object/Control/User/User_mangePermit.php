<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_mangePermit {
	/*
	 * 管理用户权限
	 */
	function mangePermit() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
			
		$dao = MooDao::get('Group');
		$group = $dao->getALl('select * from @TABLE where 1');
		
		$res = array();
		foreach ($group as $k => $val) {
			$data['group_id'] = $val['group_id'];
			$data['group_name'] = $val['group_name'];
			$data['group_permission'] = json_decode($val['group_permission'], true);
			$data['group_dec']	= $val['group_dec'];
			$res[$data['group_id']] = $data;
		}
		MooView::set('permit', $res);
		
		MooView::render('managePermit');
	}

}