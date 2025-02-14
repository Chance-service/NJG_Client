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
		$gameTag = MooConfig::get('main.gameTag');
		$sqlName = $gameTag . "_game.sql";
		if (empty($_FILES)) {
			MooView::set('gameName', $gameTag);
			MooView::set('fileName', $sqlName);
			MooView::render('uploadSql');
		} else {
			if ($_FILES["file"]["name"] != $sqlName) {	
				$message = "文件名错误!,请上传".$sqlName;
				MooView::set('message', $message);
				MooView::render('uploadSql');
				exit;
			}
			$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/tools/sql/" . $_FILES["file"]["name"];	
    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
    			$message = "上传" . $sqlName . "成功!";
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
 	