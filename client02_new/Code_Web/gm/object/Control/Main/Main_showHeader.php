<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 头部
* $Id: Main_showHeader.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_Main_showHeader {
	function showHeader() {

		// 登录用户信息
		$session = MooObj::get('User')->getSession();

		// 权限控制
		MooView::set('permission', $session['permission']);
		
		// 用户名字
		MooView::set('userName', $session['user']['user_name']);

		// 加载模板
		MooView::render('showHeader');
	}
}