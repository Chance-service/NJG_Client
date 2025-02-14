<?php
require_once 'common.php';
ini_set('memory_limit',"1256M");
$endRs = array();

$re = array();
// 安卓1服
/*
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'wow';
$conf['char'] 	= 'utf8';
*/
$conf = array();
$conf['host'] 	= '10.59.3.50:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= 'youai@2015!';
$conf['dbName'] = 'wow';
$conf['char'] 	= 'utf8';

	
$link = mysql_connect($conf['host'], $conf['user'], $conf['pwd']);	
if (!$link) {
	echo '数据库连接失败!' . mysql_error();
	exit;
}

if (!@mysql_select_db($conf['dbName'])) {
	echo '选择数据库失败' . mysql_error();
	exit;
}		
mysql_set_charset($conf['char']);

// dau		
$sql 	= "SELECT * FROM  `equip` where playerId <= 81865";
$result = mysql_query($sql, $link);

$rsArr = array();
while($res = mysql_fetch_array($result)) {
	$rsIds[0] = $res['playerId'];
	$rsIds[1] = $res['equipId'];	
	$rsIds[2] = $res['primaryAttrType1'];
	$rsIds[3] = $res['primaryAttrValue1'];
	$rsIds[4] = $res['primaryAttrType2'];
	$rsIds[5] = $res['primaryAttrValue2'];
	$rsIds[6] = $res['secondaryAttrType1'];
	$rsIds[7] = $res['secondaryAttrValue1'];
	$rsIds[8] = $res['secondaryAttrType2'];
	$rsIds[9] = $res['secondaryAttrValue2'];
	$rsIds[10] = $res['secondaryAttrType3'];
	$rsIds[11] = $res['secondaryAttrValue3'];
	$rsIds[12] = $res['secondaryAttrType4'];
	$rsIds[13] = $res['secondaryAttrValue4'];
	$rsArr[] = $rsIds;
}

// 标题框
$excelRs = array(
	1 => array(
		0 => 'playerId',
		1 => 'equipId',
		2 => 'primaryAttrType1',
		3 => 'primaryAttrValue1',
		4 => 'primaryAttrType2',
		5 => 'primaryAttrValue2',
		6 => 'secondaryAttrType1',
		7 => 'secondaryAttrValue1',
		8 => 'secondaryAttrType2',
		9 => 'secondaryAttrValue2',
		10 => 'secondaryAttrType3',
		11 => 'secondaryAttrValue3',
		12 => 'secondaryAttrType4',
		13 => 'secondaryAttrValue4',
	),
);	

$excelRs = array_merge($excelRs, $rsArr);

$writeExcelArr[0]['name'] = 'equip';
$writeExcelArr[0]['data'] = $excelRs;

$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('equip.xls', $writeExcelArr);
// var_dump($rs);

$pathFile = ROOT_PATH . "/www/equip.xls";	

// 下载文件
downFile($pathFile, 'equip.xls');


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


?>
