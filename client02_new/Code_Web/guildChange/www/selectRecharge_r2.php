<?php
require_once 'common.php';

// 登录后 设置权限
$rs = MooObj::get('Control_ExcelConfMaker')->selectRecharge();

$path = ROOT_PATH . "/doc/excel/selectData/" . "selectRecharge.xls";	
if($rs) {
	downFile($path, "selectRecharge.xls");
}
function downFile($filepath, $fileName) {
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