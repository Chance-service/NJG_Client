<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];

$date = $_REQUEST['date'];
if (!$date) {
	$date = date('Y-m-d');
}

$endRs = array();

$re = array();
// 安卓1服
for($serverId = 1; $serverId <= count($androidDbs); $serverId ++) {
$conf = $androidDbs[$serverId];
/*
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'dragon_game';
$conf['char'] 	= 'utf8';	
*/
	
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
$startTime 	= strtotime($date);
$endTime 	= strtotime($date) + 86400;		
$sql 	= "SELECT puid,deviceId,lastlogin FROM  `player` WHERE  lastlogin >= ".$startTime." and lastlogin < ".$endTime. " order by lastlogin asc";
$result = mysql_query($sql, $link);

$platform = 'android';

$rsArr = array();
while($res = mysql_fetch_array($result)) {
	$rsIds[0] = $platform.'-'.$serverId;
	$rsIds[1] = $res['puid'];	
	$rsIds[2] = $res['deviceId'];
//	$rsIds[3] = date('Y-m-d H:i:s', $res['lastlogin']);
	$rsArr[] = $rsIds;
}
$re[$platform.'-'.$serverId] = $rsArr;
}

//ios
for($serverId = 1; $serverId <= count($iosDbs); $serverId ++) {
$conf = $iosDbs[$serverId];

/*
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'dragon_game';
$conf['char'] 	= 'utf8';	
*/
	
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
$startTime 	= strtotime($date);
$endTime 	= strtotime($date) + 86400;		
$sql 	= "SELECT puid,deviceId,lastlogin FROM  `player` WHERE  lastlogin >= ".$startTime." and lastlogin < ".$endTime.  " order by lastlogin asc";;
$result = mysql_query($sql, $link);

$platform = 'ios';

$rsArr = array();
while($res = mysql_fetch_array($result)) {
	$rsIds[0] = $platform.'-'.$serverId;
	$rsIds[1] = $res['puid'];	
	$rsIds[2] = $res['deviceId'];
//	$rsIds[3] = date('Y-m-d H:i:s', $res['lastlogin']);
	$rsArr[] = $rsIds;
}
$re[$platform.'-'.$serverId] = $rsArr;
}

$resultArr = array();
foreach($re as $key => $val) {
	$resultArr = array_merge($resultArr, $val);
}
// 去掉重复后
$devIds = array();
foreach($resultArr as $key => $val) {
	$devIds[$val[2]] = 1;
}

$TotalDau = count($devIds);
// 标题框
$excelRs = array(
	0 => array(
		0 => '',
		1 => $date . '用户登录DAU(去重后):',
		2 => $TotalDau,
	//	3 => '',
	),
	1 => array(
	    0 => 'serverId',
		1 => 'puid',
		2 => 'deviceId',
	//	3 => 'deviceId',
	),
);	

$excelRs = array_merge($excelRs, $resultArr);

$writeExcelArr[0]['name'] = $date . '全服DAU';
$writeExcelArr[0]['data'] = $excelRs;

$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write($date.'.dau.xls', $writeExcelArr);
// var_dump($rs);

$pathFile = ROOT_PATH . "/www/" . $date.'.dau.xls';	

// 下载文件
downFile($pathFile, $date.'.dau.xls');

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
