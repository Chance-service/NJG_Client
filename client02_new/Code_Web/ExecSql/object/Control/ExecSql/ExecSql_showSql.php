<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_showSql {
	
	function showSql() {	

		$gameTag = MooConfig::get('main.gameTag');
		if(!$gameTag) {
			exit("请添加gameTag信息!");
		}

		$confName = $gameTag . "_execsqldbconfig"; 
		
		$CONF = MooConfig::get($confName);	
		
		// 渠道
		if (!$CONF) return false;
		$channel = array();
		foreach ($CONF as $key => $value) {
			$channel[] = $key;
		}
	
		// 游戏信息
		MooView::set('gameId', $gameTag);
		
		// 分配 渠道
		MooView::set('channel', $channel);
		MooView::render('showSql');
	}
}	
 	