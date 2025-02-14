<?php
$CONF = array();

// localhost替换服务器上ip
$CONF['staticUrl'] = 'http://localhost/gm/www/static/';
$CONF['timeLimit'] = '10';	// 查询数据设置超时单位(秒)
$CONF['viewAll'] = 0;	// 显示全部  0 关闭, 1开启

$CONF['defaultGame'] = "wow";	

// 数据查询url地址
$CONF['url'] = array(
	'fetch_operation' => "http://182.254.230.39:9001/fetch_operation", 	// 获取实时数据
	'fetch_statistics' => "http://182.254.230.39:9001/fetch_statistics",  // 获取历史数据
	'daily_analyze' => "http://182.254.230.39:9001/daily_analyze",	// 手动运算运营数据
	'fetch_game'   => 'http://182.254.230.39:9001/fetch_game',		// 获取游戏信息
	'create_game'   => 'http://182.254.230.39:9001/create_game',	// 创建游戏
	'fetch_server'  => 'http://182.254.230.39:9001/fetch_server',	// 获取服务器
	'fetch_general'  => 'http://182.254.230.39:9001/fetch_general',	// 获取指定日期 平台 渠道 数据
);

// 充值对账 Url
$CONF['rechargeUrl'] = array(
	'fetch_order' => "http://182.254.230.39:9001/fetch_order", 		  // 游戏订单查询
	'fetch_recharge' => "http://182.254.230.39:9001/fetch_recharge",  // 获取指定puid 的订单
	'fetch_bills' => "http://182.254.230.39:9001/fetch_bills",		  // 获取指定渠道的特定时间段的订单
);

// 数据分析
$CONF['dataAnalysis'] = array(
		'fetch_gold_source' => "http://182.254.230.39:9001/fetch_gold?changetype=1", 		  // 砖石来源
		'fetch_gold_use' => "http://182.254.230.39:9001/fetch_gold?changetype=2", 		  	  // 砖石消耗
		'fetch_tutorial_step'=> "http://182.254.230.39:9001/fetch_tutorial_step",			  // 新手步骤
		'fetch_tutorial_level'=> "http://182.254.230.39:9001/fetch_tutorial_level"			  // 新手等级
);

// cdk服务器地址
$CONF['cdkUrl'] = "http://182.254.230.39:9000";
