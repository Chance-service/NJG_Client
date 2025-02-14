<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_uploadSqlExcel {
	
	function uploadSqlExcel() {
		
		$show = MooForm::request('show');
		$gameId = MooForm::request('gameId');
		$gameInfo = MooObj::get('Publish')->getGameInfo($gameId);
		if (!$gameInfo) {
			exit('找不到该游戏信息！');
		}
		$gameName = $gameInfo['gameName'];	
		$gameTag  = $gameInfo['gameTag'];
		if ($show && $show == 'view') {
			MooView::set('gameId', $gameId);	
			$mod = 'make'.$gameTag.'SqlConf';
			MooObj::get('Control_ExcelConfMaker')->$mod();				
			MooView::render('uploadSqlExcel');	
		} else {
			if (empty($_FILES)) {
				MooView::set('gameId', $gameId);
				MooView::set('gameName', $gameName);
				MooView::set('fileName', $gameTag.'_sql_hosts.conf.xls');
				MooView::render('uploadSqlExcel');
			} else {
				$fileName = $gameTag.'_sql_hosts.conf.xls';	
				if ($_FILES["file"]["name"] != $fileName) {	
					$message = "文件名错误!,请上传" . $fileName;
					MooView::set('message', $message);
					MooView::render('uploadSqlExcel');
					exit;
				}
				$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/doc/excel/" . $_FILES["file"]["name"];	
	    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
	    			$message = "上传".$fileName."成功!";
					MooView::set('message', $message);					
					$mod = 'make'.$gameTag.'SqlConf';
					MooObj::get('Control_ExcelConfMaker')->$mod();				
					MooView::render('uploadSqlExcel');
	    		} else {
	    			$message = "上传".$fileName."失败!";
					MooView::set('message', $message);
					MooView::render('uploadSqlExcel');			
		    	}		
			}	
			
		}
	
	}
}	
 	