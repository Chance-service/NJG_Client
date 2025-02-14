<?php
$CONF = array();

// localhost替换服务器上ip
$CONF['staticUrl'] = 'http://203.195.147.186/downloadOrders/www/static/';
$CONF['timeLimit'] = '200';	// 查询数据设置超时单位(秒)
$CONF['viewAll'] = 0;	// 显示全部  0 关闭, 1开启

$CONF['game'] = array(
		'hwgj'
);

$CONF['getServersUrl'] = "http://125.209.197.65/RechargeServers.php";
// 服信息备份
$CONF['servers'] = array(
		1 => '1server',
		2 => '2server',
		3 => '3server',
		4 => '4server',
		5 => '5server',
		6 => '6server',
		7 => '7server',
		8 => '8server',
);

// 充值对账 Url 
// http://125.209.197.65/RechargeList.php?startDate=2015-03-22&endDate=2015-03-24&serverId=8

$CONF['rechargeUrl'] = array(
	'fetch_bills' => "http://125.209.197.65/RechargeList.php",		  // 获取指定渠道的特定时间段的订单
);
