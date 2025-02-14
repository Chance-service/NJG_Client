<?php
/**
 * document 执行sql 配置文件 android ios 是 渠道   1 2 3 是 服
 */

$CONF = array(
	'localhost' => array(
		// 本地	localhost
		'1'	 => array(
				'host' => 'localhost:3306',  	// 服务器   + 端口
				'user' => 'root',				// 用户名
				'pwd'  => '123456',		// 密码
				'dbName'  => 'testDb',		// 数据库名
				'char'  => 'utf8',				// 设置编码格式
		),
	),
	'R2_test' => array(
		// 本地	localhost
		'1'	 => array(
			'host' => '10.8.14.235:3306',  	// 服务器   + 端口
			'user' => 'root',				// 用户名	
			'pwd'  => 'ur2MGUb4inMwzb',		// 密码
			'dbName'  => 'gjabd_r2',		// 数据库名
			'char'  => 'utf8',				// 设置编码格式
		),
	),
	'gNetop_Jp_test' => array(
		// 本地	localhost
		'1'	 => array(
				'host' => '10.8.14.235:3306',  	// 服务器   + 端口
				'user' => 'root',				// 用户名
				'pwd'  => 'ur2MGUb4inMwzb',		// 密码
				'dbName'  => 'gjabd_gnetop',	// 数据库名
				'char'  => 'utf8',				// 设置编码格式
		),
	),
	'Efun_test' => array(
			// 本地	localhost
			'1'	 => array(
					'host' => '10.8.14.235:3306',  	// 服务器   + 端口
					'user' => 'root',				// 用户名
					'pwd'  => 'ur2MGUb4inMwzb',		// 密码
					'dbName'  => 'gjabd',	// 数据库名
					'char'  => 'utf8',				// 设置编码格式
			),
	)
);