<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_uploadSql {
	
	function uploadSql() {
		
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];		
		$sqlNames = $gameTag.'_game.sql';
		
		if (empty($_FILES)) {
			MooView::set('gameId', $gameId);
			MooView::set('gameName', $gameName);
			MooView::set('fileName', $sqlNames);		
			MooView::render('uploadSql');
		} else {
			if ($_FILES["file"]["name"] != $sqlNames) {	
				$message = "文件名错误!,请上传".$sqlNames;
				MooView::set('message', $message);
				MooView::render('uploadSql');
				exit;
			}
			$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/tools/sql/" . $_FILES["file"]["name"];	
    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
    			$message = "上传成功!";
				MooView::set('message', $message);
				MooView::render('uploadSql');
    		} else {
    			$message = "上传失败!";
				MooView::set('message', $message);
				MooView::render('uploadSql');
    			
    		}
		}	
	}
}	
 	