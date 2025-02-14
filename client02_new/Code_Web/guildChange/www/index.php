<?php
require_once 'common.php';

// 静态文件url
MooView::set('staticUrl', MooConfig::get('main.staticUrl'));

$mod = MooForm::request('mod');
$do = MooForm::request('do');

MooObj::get('Control')->checkAction($mod, $do);

// require_once ROOT_PATH . "/conf/serverConfig.php"; // 走配置
require_once "/data/nginx/htdocs/config/serverConfig.php";  // 走api配置
MooView::set('serverLists', $serverConfig);
if(!$mod && !$do) {
	MooView::render('api');
}

// 进行相关处理
MooObj::get('Control_' . $mod)->$do();

