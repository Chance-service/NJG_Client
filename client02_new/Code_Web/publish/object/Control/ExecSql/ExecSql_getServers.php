<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_getServers {
	
	function getServers() {
		
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];
		
		$conf = MooConfig::get($gameTag . '_execsqldbconfig');
		
		// 渠道名称
		$channelName = MooForm::request('appLabel');
		$channelConf = $conf[$channelName];
		
		$servers = array();
		foreach ($channelConf as $server => $value) {
			$servers[$server] = $server."服"; 
		}

		echo count($servers);
	}
}	
 	