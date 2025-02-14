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
		$gameTag = MooConfig::get('main.gameTag');
		$sqlConfName = $gameTag . "_" . 'execsqldbconfig.conf.php';
		
		if (empty($_FILES)) {
			MooView::set('fileName', $sqlConfName);
			MooView::render('uploadSqlConf');
		} else {
			if ($_FILES["file"]["name"] != $sqlConfName) {	
				$message = "文件名错误!,请上传" . $sqlConfName;
				MooView::set('message', $message);
				MooView::render('uploadSqlConf');
				exit;
			}
			$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/conf/" . $_FILES["file"]["name"];	
    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
    			$message = "上传".$sqlConfName."成功!";
				MooView::set('message', $message);
				MooView::render('uploadSqlConf');
    		} else {
    			$message = "上传失败!";
				MooView::set('message', $message);
				MooView::render('uploadSqlConf');
    			
    		}
		}	
	}
}	
 	