<?php
$CONF = array();
// http://localhost:5132/silent?params=playerid:1;type:1&user:hawk
// 参数 type 可选
$CONF['action'] = array(
	'0' => array(
			'id'   => 0,
			'desc' => '封号',
			'cmd' => 'forbiden',
			'type' => 1,
	),
	'1' => array(
			'id'   => 1,
			'desc' => '解封',
			'cmd' => 'forbiden',
			'type' => 2,
	),
	'2' => array(
			'id'   => 2,
			'desc' => '禁言',
			'cmd' => 'silent',
			'type' => 1,
	),
	'3' => array(
			'id'   => 3,
			'desc' => '解禁言',
			'cmd' => 'silent',
			'type' => 2,
	),
	'4' => array(
			'id'   => 4,
			'desc' => '踢出玩家',
			'cmd' => 'kick',
	),
	'5' => array(
			'id'   => 5,
			'desc' => '清除内存',
			'cmd' => 'clearplayer',
	),

	'6' => array(
			'id'   => 6,
			'desc' => '跨天数据重置',
			'cmd' => 'fixoverday',
	),
);