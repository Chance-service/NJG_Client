<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_doGoRunSql {
	
	function doGoRunSql() {
		
		
		$channelName = MooForm::request('channelName');
		$serverIds 	 = MooForm::request('serverIds');			// 字符串
		$serverIds = substr($serverIds,0,strlen($serverIds)-1); // 去除最后一个字符
		$action 	 = MooForm::request('action');		
		$serverIds   = explode(",",$serverIds);
		
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];
	

		if (!$channelName || !$serverIds || !$action) {
			$res['code'] = 0;
			$res['msg']  = "执行失败!";
			echo MooJson::encode($res);
			exit;
		}
		// 返回数据
		$rs = "";
		if ($serverIds) {
			// 循环执行
			foreach ($serverIds as $key => $serverId) {
			 	$rs .= MooObj::get('Control_ExecSql')->goRunSql($channelName, $serverId, $action, $gameTag) . "</br>";
			}
		}
		
		$res = array();
		$res['code'] = 1;
		
		// 处理 sql 格式
		$rs =	str_replace('__','<br>', $rs);	
		$rs =	str_replace('` (','` (<br>', $rs);	
		$rs =	str_replace(';',';<br>', $rs);	
		$rs	= 	str_replace(',',',<br>', $rs);			
		$res['msg']  = $rs;
		
		echo MooJson::encode($res);
	}
}	
 	