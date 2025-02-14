<?php
/**
 * document 执行sql 配置文件 android ios 是 渠道   1 2 3 是 服
 */

$CONF = array();
$CONF = array(
	
	'Android-All' => array(
		// 安卓1服 	203.195.147.135
		'1'	 => array(
			'host' => '10.66.107.211:3306',  // 服务器   + 端口
			'user' => 'root',				// 用户名	
			'pwd'  => 'Gmr1RHpDe!zXaE',		// 密码
			'dbName'  => 'lol_game',		// 数据库名
			'char'  => 'utf8',				// 设置编码格式
		),
		// 安卓2服  203.195.147.60
		'2'	 => array(
			'host' => '10.66.110.60:3306',  // 服务器   + 端口
			'user' => 'root',				// 用户名	
			'pwd'  => '(BJOBKHbrwEyCZjw',	// 密码
			'dbName'  => 'lol_game',		// 数据库名
			'char'  => 'utf8',				// 设置编码格式
		),
		// 安卓3服  203.195.182.97
		'3'	 => array(
			'host' => '10.66.111.86:3306',  // 服务器   + 端口
			'user' => 'root',				// 用户名	
			'pwd'  => 'u8gWZ!cOJmqVS65',	// 密码
			'dbName'  => 'lol_game',		// 数据库名
			'char'  => 'utf8',				// 设置编码格式
		),
		// 安卓4服  203.195.221.90
		'4'	 => array(
			'host' => '10.66.111.84:3306',  // 服务器   + 端口
			'user' => 'root',				// 用户名	
			'pwd'  => 'gpCYljFkmyvd0Iz',	// 密码
			'dbName'  => 'lol_game',		// 数据库名
			'char'  => 'utf8',				// 设置编码格式
		)
	),
	
	'IOS-All' => array(
		// ios 1服   203.195.147.126
		'1'	 => array(
			'host' => '10.66.1.122:1038',
			'user' => 'root',
			'pwd'  => 'd*GCoomhM6Tp4Mne)z',
			'dbName'  => 'lol_game',
			'char'  => 'utf8',
		),
		// 2服  203.195.223.19
		'2'	 => array(
			'host' => '10.66.104.104:3306',
			'user' => 'root',
			'pwd'  => 'NcL1mpTYvt8MV6y',
			'dbName'  => 'lol_game',
			'char'  => 'utf8',
		)
	),
	
	'APP-store' => array(
		// appstore    203.195.222.56
		'1'	 => array(
			'host' => '10.66.104.106:3306',
			'user' => 'root',
			'pwd'  => 'KLqS%^kv)ubpxR8',
			'dbName'  => 'lol_game',
			'char'  => 'utf8',
		)
	)

);

