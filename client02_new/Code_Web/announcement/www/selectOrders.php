<?php
require_once 'common.php';


$endRs = array();
// 安卓1服



$conf = array();
$conf['host'] 	= '127.0.0.1:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'rechargeback';
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

// 统计11 - 16日 所有华为渠道的充值数据
$startTime 	= "2015-04-09 00:00:00";
$endTime 	= "2015-04-10 00:00:00";		
$sql 	= "SELECT * FROM  `pay_process_info`,`player` WHERE  gs_send_time >= ".$startTime." and create_time < ".$endTime ."  order by server_idx asc, gs_send_time asc";
$result = mysql_query($sql, $link);

$rsIdPuIds = array();
$i = 0;
while($res = mysql_fetch_array($result)) {
	$i++;
	$arr['0'] = $i;
	$arr['1'] = $res['server_idx'];
	$arr['2'] = $res['puid'];
	$arr['3'] = $res['order_id'];
	$arr['4'] = $res['gs_send_time'];
	$arr['5'] = $res['product_id'];
	$rsIdPuIds[] = $arr;
}

$rsExcel['name'] = "r2_recharge";
$rsExcel['data'] = $rsIdPuIds;

$endRs[] = $rsExcel;

// 标题框
$excelRs = array(
	0 => array(
		0 => '',
		1 => '',
		2 => 'r2_recharge',
		3 => '',
		4 => '',
		5 => '',
	),
	1 => array(
		0 => '序号',
		1 => '服id',
		2 => 'puid',
		3 => 'order_id',
		4 => 'gs_send_time',
		5 => 'product_id',
	),
);	

$excelRs = array_merge($excelRs, $val['data']);

echo "<pre>";
print_r($excelRs);
echo "</pre>";

$writeExcelArr[0]['name'] = '11月11日至16日华为渠道充值详细';
$writeExcelArr[0]['data'] = $excelRs;

echo "<pre>";
print_r($writeExcelArr);
echo "</pre>";


$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('r2_recharge.xls', $writeExcelArr);

var_dump($rs);


?>
