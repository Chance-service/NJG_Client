<?php
// 时区
date_default_timezone_set('Asia/Shanghai');
define('ROOT_PATH', dirname(__FILE__));

header("Access-Control-Allow-Origin: *");

// 框架
require_once ROOT_PATH . '/MooPHP/common.php';

// 数据库
require_once ROOT_PATH . '/inc/globalobj.inc.php';
require_once ROOT_PATH . '/inc/dbfactory.inc.php';

