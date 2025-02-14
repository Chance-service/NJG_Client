<?php
$CONF = array();
// http://localhost:5132/silent?params=playerid:1;type:1&user:hawk
// 参数 不传递参数
$CONF['action'] = array(
	'0' => array(
			'id'   => 0,
			'desc' => '内存数据落地',
			'cmd' => 'dbland',
	),
	'1' => array(
			'id'   => 1,
			'desc' => '刷新配置文件',
			'cmd' => 'xmlcheck',
	),
	'2' => array(
			'id'   => 2,
			'desc' => '清除聊天缓存',
			'cmd' => 'clearchat',
	),
	
);