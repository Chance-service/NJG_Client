<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 退出
* $Id: User_logout.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_logout {
	/**
	 * 退出
	 *
	 * @return  void
	 */
	function logout() {
		MooObj::get('User')->logout();
	}
}