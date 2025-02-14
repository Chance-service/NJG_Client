<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 首页
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_Main_showWelcome {
	function showWelcome() {

		$statStart = $statStart ? $statStart : date('Y/m') . '/01';
		$statEnd = $statEnd ? $statEnd : date('Y/m/d');

		// 应用列表
		$appList = MooObj::get('App')->getList();

		// 平台列表
		$platformList = MooObj::get('App_Platform')->getList();

		// 日志列表
		$unusualList = MooObj::get('Log_PubLog')->getUnusualList($appLabel, $platformLabel, $vhostVersion, $statStart, $statEnd);

		foreach($unusualList as $key=>$stat) {
			$unusualList[$key]['app_name'] = $appList[$stat['app_label']]['app_name'];
			$unusualList[$key]['platform_name'] = $stat['platform_label'] ? $platformList[$stat['platform_label']]['platform_name'] : '';
		}

		MooView::set('statStart', $statStart);
		MooView::set('statEnd', $statEnd);
		MooView::set('unusualList', $unusualList);

		MooView::render('showWelcome');
	}
}