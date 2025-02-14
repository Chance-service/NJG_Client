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
		// 设置session
		$uId = MooSession::get('uId');
		$name = MooSession::get('name');
		MooView::set('uId', $uId);	
		MooView::set('name', $name);
	}
}