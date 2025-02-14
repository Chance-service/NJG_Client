<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_uploadDataExcel {
	
	function uploadDataExcel() {
		
		$show = MooForm::request('show');		
		$fileName = 'selectData.conf.xls';	
		
		if ($show && $show == 'view') {
	
			MooView::set('fileName',$fileName);	
			
			MooView::render('uploadDataExcel');	
		} else {
				$excelName = "selectData.conf.xls";	
				MooView::set('fileName',$excelName);
			if (empty($_FILES)) {
				MooView::render('uploadDataExcel');
			} else {
				if ($_FILES["file"]["name"] != $fileName) {	
					$message = "文件名错误!,请上传" . $fileName;
					MooView::set('message', $message);
					MooView::render('uploadDataExcel');
				}
				
				$path = dirname(dirname(dirname(dirname(__FILE__)))) . "/doc/excel/" . $_FILES["file"]["name"];	
	    		if(move_uploaded_file($_FILES["file"]["tmp_name"], $path)) {
	    			$message = "上传".$fileName."成功!";
					MooView::set('message', $message);	
					$rs = MooObj::get("Control_ExcelConfMaker")->selectData();
			
					MooView::render('uploadDataExcel');
	    		} else {
	    			$message = "上传".$fileName."失败!";
					MooView::set('message', $message);
					MooView::render('uploadDataExcel');			
		    	}		
			}	
			
		}
	
	}
}	
 	