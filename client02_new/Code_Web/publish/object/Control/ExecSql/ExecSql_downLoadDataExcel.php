<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project 执行sql 更新数据库
* document
* $Id: Main_showWelcome.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_ExecSql_downLoadDataExcel {
	
	function downLoadDataExcel() {

		$fileName = "selectDataResult.xls";
		$pathFile = ROOT_PATH . "/doc/excel/selectData/" . "selectDataResult.xls";	
		
		$this->downFile($pathFile, $fileName);	
	}
	
	private function downFile($filepath, $fileName) {
		$fp			=	fopen($filepath,"r"); 
		$file_size	=	filesize($filepath); 
		//下载文件需要用到的头 
		header("Content-type: application/octet-stream"); 
		header("Accept-Ranges: bytes"); 
		header("Accept-Length:".$file_size); 
		header("Content-Disposition: attachment; filename=".$fileName); 
		$buffer		=	1024; 
		$file_count	=	0; 
		//向浏览器返回数据 
		while(!feof($fp) && $file_count < $file_size){ 
		$file_con	=	fread($fp,$buffer); 
		$file_count	+=	$buffer; 
		echo $file_con; 
		} 
		fclose($fp); 
	}
	
}	
 	