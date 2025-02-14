<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];


$endRs = array();
// ios 1- 34服
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

$sql = "SELECT sum(`count`) as num FROM `bag` WHERE `itemid` = 50005";
$result = mysql_query($sql, $link);

$platform = 'ios';
// 存储id 和 puid
$rsIdPuIds = array();
$rsIds = array();

$rsIdPuIds[$platform .'-'. $serverId] = array(
);

$i = 0;
while($res = mysql_fetch_array($result)) {
	$i++;
	$arr['0'] = $i;
	$arr['1'] = $platform .'-'. $serverId;
	$arr['2'] = $res['num'];
	$rsIdPuIds[$platform .'-'. $serverId][] = $arr;
	$rsIds[] = $res['playerId'];
}

$rsExcel['name'] = $platform .'-'. $serverId;
$rsExcel['data'] = $rsIdPuIds[$platform .'-'. $serverId];

$endRs[] = $rsExcel;

}
// 标题框
$excelRs = array(
	0 => array(
		0 => '',
		1 => 'datas',
		2 => '',
	),
	1 => array(
		0 => '序号',
		1 => '所在服',
		2 => '50005饲料数量',
	),
);	
foreach ($endRs as $key => $val) {
	$excelRs = array_merge($excelRs, $val['data']);
}

$writeExcelArr[0]['name'] = '饲料50005数量';
$writeExcelArr[0]['data'] = $excelRs;

echo "<pre>";
print_r($writeExcelArr);
echo "</pre>";


$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('50005.xls', $writeExcelArr);

var_dump($rs);




?>
