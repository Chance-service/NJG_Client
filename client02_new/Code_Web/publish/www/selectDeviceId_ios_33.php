<?php
require_once 'common.php';

$dbconfigs = MooConfig::get('lz_execsqldbconfig');
$androidDbs = $dbconfigs['Android-All'];
$iosDbs = $dbconfigs['IOS-All'];


$endRs = array();
// 安卓1服
for($serverId = 33; $serverId <= 33; $serverId ++) {
$conf = $iosDbs[$serverId];

	
$conf = array();
$conf['host'] 	= '10.0.3.240:3306';
$conf['user'] 	= 'root';
$conf['pwd']  	= '123456';
$conf['dbName'] = 'dragon_game';
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
$startTime 	= strtotime("2014-11-11");
$endTime 	= strtotime("2014-11-17");		

/*
$deviceIds = '("win32Device",
"865521016306119"
)';
*/

$deviceIds = '("ca342a1562ca8f031aceb13631b0f543",
"ca3d77b5638df5e30459d5181cf95341",
"ccfd0d777236a31ed81eeff6b67d49d4",
"cfebe578f590126c335d41c7566e92e1",
"d1947a6ec38adc3e965adab1a3f8fc5b",
"d3f172d6fcab6974e94d79ae0cb9fa1b",
"d441ad625f845435577df656efddc1f5",
"d4c517f382c9c5c32e8db428a2fe7019",
"d95f6444ea8a68b14dc16426eadb1ba3",
"da2f05f9d8793fa79c38afdbc2f91a2a",
"da36d3d3f194f6b41c98aaae01eaa1c1",
"daa7d737cba7476214b617eaf16f5099",
"dac2310cc49cba0cf8f693dc1e5a4194",
"dca4601ec7735c815e8276812725929f",
"dcd5d5db8cbfddcb0ac26a0165530019",
"ddb4623d4fba90f4d769701de2bc0a78",
"deb2c073ac3f88d2b7c3268e9d17c29d",
"dfcabadddfd097ed7a382fb7062381f7",
"e010a0748d8bbca4e893c156db8654d3",
"e11da5c41364557c4f6d1d47c513c2b4",
"e1459ea8940036c0eaa1bb5df0b1f231",
"e1c2b406e54b208ab250a2b708d239d6",
"e29ad2dd521b25d1813f0c16e5e20824",
"e485dd397d3a1d84768c9aee1f08855c",
"e518a7023a965076facd9c51d4458aa1",
"e622f754731e0b11602e9030dde40dac",
"e62d6e2baefb5c26265a3ed901ece728",
"e63de1c6f68983e9166a20c6afbb3162",
"e6d88efee354bd61bcf0a6a032fca197",
"e7e17533174dc81ec1a26eba2c85f3ef",
"e920788aab4926ed1721885944fa51f2",
"eb9bc6f09be96f836789558ff5e294be",
"ed7159d26cf80b3535de06c5b5e8e1a6",
"ed933202c4cfcc395a1b9802430671a0",
"ee709c8476d1505370e95b05a33ad951",
"ef8bb74f37dfbf7712822c7833d12618",
"efc04300799223cc8451f889894da877",
"f0aaf31b021a2dc8a2f89ef6f177aef4",
"f0c67b3142f106d5fca3a2acf51a7610",
"f110ab9d384ebfe55103f0dc1ac13095",
"f15fc82f23b3f5afd6ac082877cd7c5e",
"f39b9fc700376474c5c2cea8a93ba737",
"f3cf1dae4f1bf16bc5e4cd5502de1bb4",
"f3e5e382b976be5db6bddee437220b9f",
"f458019fae2bfe8da82c01a5a12fbe0c",
"f4cd7bff071bb7704c1f580574cc90f7",
"f6a8a84f375f6f1154e1ebfa54ccbb9f",
"f9aa66b1c50f85d7394a603f087facfa",
"fc4525b4135a224bf9d0aaa30dbfce3a")';

$sql 	= "SELECT deviceId,puid,registertime FROM `player` WHERE  `deviceId` in " . $deviceIds;

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
	$arr['1'] = $res['puid'];
	$arr['2'] = $res['deviceId'];
	$arr['3'] = date('Y-m-d H:i:s', $res['registertime']);
	$arr['4'] = $platform .'-'. $serverId;
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
		2 => '设备id查询',
		3 => '',
		4 => '',
	),
	1 => array(
		0 => '序号',
		1 => 'puid',
		2 => 'deviceId',
		3 => '注册时间',
		4 => '所在服',
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

exit;
$rs = MooObj::get('Control_ExcelConfMaker_Excel')->write('deviceIds_ios33.xls', $writeExcelArr);

var_dump($rs);

exit;
echo "<pre>";
print_r($endRs);
echo "</pre>";




?>
