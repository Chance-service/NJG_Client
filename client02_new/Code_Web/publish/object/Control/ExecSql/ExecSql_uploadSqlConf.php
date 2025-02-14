<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_uploadSqlConf {
	
	function uploadSqlConf() {
		
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];
		
		if (empty($_FILES)) {
			MooView::set('gameId', $gameId);
			MooView::set('gameName', $gameName);
			MooView::set('fileName', $gameTag.'_execsqldbconfig.conf.php');
			MooView::render('uploadSqlConf');
		} else {
				$fileName = $gameTag.'_execsqldbconfig.conf.php';	
				if ($_FILES["file"]["name"] != $fileName) {	
					$message = "文件名错误!,请上传" . $fileName;
					MooView::set('message', $message);
					MooView::render('uploadSqlConf');
					exit;
				}
				$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/conf/" . $_FILES["file"]["name"];	
	    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
	    			$message = "上传".$fileName."成功!";
					MooView::set('message', $message);
					MooView::render('uploadSqlConf');
	    		} else {
	    			$message = "上传".$fileName."失败!";
					MooView::set('message', $message);
					MooView::render('uploadSqlConf');
	    			
	    	}		
		}	
	}
}	
 	