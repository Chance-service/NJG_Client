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
			
		$dao = MooDao::get('Permit');
		$group = $dao->getALl('select * from @TABLE where 1');
		
		$res = array();
		foreach ($group as $k => $val) {
			$data['group_id'] = $val['cp_id'];
			$data['group_name'] = $val['cp_name'];
			$data['group_permission'] = json_decode($val['cp_permission'], true);
			$data['group_dec']	= $val['cp_desc'];
			$res[$data['group_id']] = $data;
		}
		MooView::set('permit', $res);
		
		MooView::render('managePermit');
	}

}