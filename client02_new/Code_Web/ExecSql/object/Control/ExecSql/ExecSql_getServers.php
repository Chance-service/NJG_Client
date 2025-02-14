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
		
		$gameTag = MooForm::request('gameId');
		
		$confName = $gameTag . "_execsqldbconfig";
		$conf = MooConfig::get($confName);
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
 	