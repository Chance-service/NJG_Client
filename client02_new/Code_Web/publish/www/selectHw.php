<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];


$endRs = array();
// 安卓1服
for($serverId = 1; $serverId <= 60; $serverId ++) {
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

// 统计11 - 16日 所有华为渠道的充值数据
$startTime 	= strtotime("2014-11-11");
$endTime 	= strtotime("2014-11-17");		
$sql 	= "SELECT * FROM  `recharge`,`player` WHERE  `uid` LIKE  'hw_%' and  create_time > ".$startTime." and create_time < ".$endTime ." and player.id = recharge.playerId order by goodsCost asc, create_time asc, playerId asc";
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
	$arr['4'] = date('Y-m-d H:i:s', $res['create_time']);
	$arr['5'] = $platform .'-'. $serverId;
	$arr['6'] = $res['name'];
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
		2 => '11月11日至16日华为渠道充值详细',
		3 => '',
		4 => '',
		5 => '',
		6 => '',
	),
	1 => array(
		0 => '序号',
		1 => 'playerId',
		2 => 'puid',
		3 => '充值金额',
		4 => '充值时间',
		5 => '所在服',
		6 => '角色名',
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
$writeExcelArr[0]['name'] = '11月11日至16日华为渠道充值详细';
$writeExcelArr[0]['data'] = $excelRs;

echo "<pre>";
print_r($writeExcelArr);
echo "</pre>";


$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('hwRecharge11-16_hw.xls', $writeExcelArr);

var_dump($rs);

exit;
echo "<pre>";
print_r($endRs);
echo "</pre>";




?>
