<?php
require_once 'common.php';
// 静态文件url
MooView::set('staticUrl', MooConfig::get('main.staticUrl'));
require_once ROOT_PATH . "/conf/serverConfig.php";

MooView::set('serverLists', $serverConfig);

MooView::render('api');
