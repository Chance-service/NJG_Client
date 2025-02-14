<?php
$CONF = array();

// localhost替换服务器上ip
$CONF['staticUrl'] = 'http://203.90.234.115/announcement/www/static/';
$CONF['timeLimit'] = '100';		// 查询数据设置超时单位(秒)
$CONF['nowGame']   = 'hwgj';	// 设置默认游戏

// 公告地址 配置
$CONF['url']   = array(
	'hwgj' => array(
	  // http://54.92.67.99:8080/notices/createNotice.php 
	  // http://54.92.67.99:8080/notices/announce_all/hwgj_gNetop_android_all.txt
	  // http://54.92.67.99:8080/notices/announce_all/hwgj_gNetop_ios_all.txt
	  // http://103.227.130.58/notices/announce_all/hwgj_efun_all_all.txt
	  //http://125.209.196.154/notices/announce_all/hwgj_entermate_ios_all.txt
	  //http://125.209.196.154/notices/announce_all/hwgj_entermate_android_all.txt
	   'gNetop_android' => 'http://54.92.67.99:8080/notices/createNotice.php',
	   'gNetop_ios' => 'http://54.92.67.99:8080/notices/createNotice.php',
	  'efun_all' => 'http://103.227.130.58/notices/createNotice.php',
	  'entermate_android' => 'http://125.209.196.154/notices/createNotice.php',
	   'entermate_ios' => 'http://125.209.196.154/notices/createNotice.php',
		'r2' => array(
			'English' => 'http://localhost/notices/createNotice.php',
			'French' => 'http://localhost/notices/createNotice.php',
			'German' => 'http://localhost/notices/createNotice.php',
			'Spanish' => 'http://localhost/notices/createNotice.php',
			'Portu' => 'http://localhost/notices/createNotice.php',
			'Turkish' => 'http://localhost/notices/createNotice.php',
			'Russian' => 'http://localhost/notices/createNotice.php',
		)
	),
);
