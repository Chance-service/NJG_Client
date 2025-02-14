<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑 用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_setPermit {

	function setPermit() {
		
		
		$platForm = MooConfig::get('main.platform');
		$serverId = MooConfig::get('main.serverId');
		
		// 将平台分配给前段
		MooView::set('platform', $platForm);
		MooView::set('serverId', $serverId);
		
		// 设置session
		$uId = MooSession::get('uId');
		$name = MooSession::get('name');
		$userPermission = MooSession::get('permission');	
		MooView::set('uId', $uId);	
		MooView::set('name', $name);
		$primitArray = array('p1' => 10, 'p2' => 20, 'p3' => 30, 'p4' => 40);
			
			if ($userPermission) {			// 4种权限
				foreach ($userPermission as $val) {
					if ($val == 10) {
						MooView::set('p1', $primitArray['p1']);
					}elseif ($val == 20) {
						MooView::set('p2', $primitArray['p2']);
					} elseif ($val == 30) {
						MooView::set('p3', $primitArray['p3']);
					} elseif ($val == 40) {
						MooView::set('p4', $primitArray['p4']);
					}
				}
		}
	}
}