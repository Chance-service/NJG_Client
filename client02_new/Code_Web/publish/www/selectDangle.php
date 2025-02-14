<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
// $iosDbs = $dbconfigs['Ios-All'];


$endRs = array();
// 安卓1服
for($serverId = 1; $serverId <= 63; $serverId ++) {
$conf = $androidDbs[$serverId];

/*	
$conf = array();
$conf['host'] 	= 'localhost:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '';
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

// 统计4月份 所有当乐渠道的充值数据
$startTime 	= strtotime("2014-04-01");
$endTime 	= strtotime("2014-05-01");		
$sql 	= "SELECT * FROM  `recharge`,`player` WHERE  `uid` LIKE  'dl_%' and  create_time > ".$startTime." and create_time < ".$endTime ." and player.id = recharge.playerId order by goodsCost asc, create_time asc, playerId asc";
$result = mysql_query($sql, $link);

$platform = 'android';
// 存储id 和 puid
$rsIdPuIds = array();
$rsIds = array();

$rsIdPuIds[$platform .'-'. $serverId] = array(
);

$i = 0;
while($res = mysql_fetch_array($result)) {
	$i++;
	$arr['0'] = $i;
	$arr['1'] = $res['playerId'];
	$arr['2'] = $res['uid'];
	$arr['3'] = $res['goodsCost'];
	$arr['4'] = $res['CooOrderSerial'];
	$arr['5'] = date('Y-m-d H:i:s', $res['create_time']);
	$arr['6'] = $platform .'-'. $serverId;
	$arr['7'] = $res['name'];
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
		1 => '',
		2 => '4月份当乐渠道充值详细',
		3 => '',
		4 => '',
		5 => '',
		6 => '',
		7 => '',
	),
	1 => array(
		0 => '序号',
		1 => 'playerId',
		2 => 'puid',
		3 => '充值金额',
		4 => '订单号',
		5 => '充值时间',
		6 => '所在服',
		7 => '角色名',
	),
);	
foreach ($endRs as $key => $val) {
	$excelRs = array_merge($excelRs, $val['data']);
}
/*
echo "<pre>";
print_r($excelRs);
echo "</pre>";
*/
$writeExcelArr[0]['name'] = '4月份当乐渠道充值详细';
$writeExcelArr[0]['data'] = $excelRs;

echo "<pre>";
print_r($writeExcelArr);
echo "</pre>";


$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('dangleRecharge_4.xls', $writeExcelArr);

var_dump($rs);

exit;
echo "<pre>";
print_r($endRs);
echo "</pre>";




?>
