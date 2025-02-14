<?php
$CONF = array();

// localhost替换服务器上ip
$CONF['staticUrl'] = 'http://54.173.233.19/announcement/www/static/';
$CONF['timeLimit'] = '100';		// 查询数据设置超时单位(秒)
$CONF['nowGame']   = 'hwgj';	// 设置默认游戏

// 公告地址 配置
$CONF['url']   = array(
	'hwgj' => array(
		'efun' => 'http://10.0.1.251/request.php',
		'jp' => 'http://10.0.1.251/request.php',
		'r2' => array(
			'English' => 'http://54.173.233.19/notices/createNotice.php',
			'French' => 'http://54.173.233.19/notices/createNotice.php',
			'German' => 'http://54.173.233.19/notices/createNotice.php',
			'Spanish' => 'http://54.173.233.19/notices/createNotice.php',
			'Portu' => 'http://54.173.233.19/notices/createNotice.php',
			'Turkish' => 'http://54.173.233.19/notices/createNotice.php',
			'Russian' => 'http://54.173.233.19/notices/createNotice.php',
			'Arabic' => 'http://54.173.233.19/notices/createNotice.php',
		)
	),
);
