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
		
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];
		
		$CONF = MooConfig::get($gameTag . '_execsqldbconfig');	

/*		
		var_dump($gameTag . '_execsqldbconfig');
		echo "<pre>";
		print_r($CONF);
		echo "</pre>";
		exit;
*/		
		// 渠道
		if (!$CONF) return false;
		$channel = array();
		foreach ($CONF as $key => $value) {
			$channel[] = $key;
		}
		
		// 分配 渠道
		MooView::set('gameId', $gameId);
		MooView::set('gameName', $gameName);
		MooView::set('channel', $channel);
		MooView::render('showSql');
	}
}	
 	