<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 取得用户信息
* $Id: User_getUser.php 179 2011-05-13 03:14:05Z lulu $
*/

class User_selectUser {
	/**
	 * 取得用户信息
	 *
	 * @param  $uId  用户的uid/用户名
	 * @param  $getType  获取用户方式
	 * @return   用户对象
	 */
	function selectUser() {
		// 通过用户名方式获得用户信息
		$dao = MooDao::get('User');
		$rs = $dao->load(1);
		$userInfo = $dao->getAll("select * from @TABLE");
		MooView::set('userInfo', $userInfo);
		MooObj::get('User')->setPermit();
		MooView::render("selectUser");
	}
}