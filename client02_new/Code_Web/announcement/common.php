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
// 新增 使用excel工具
require_once ROOT_PATH . '/inc/propertyList.inc.php';
require_once ROOT_PATH . '/inc/pclzip.inc.php';
require_once ROOT_PATH . '/inc/plist.inc.php';
require_once ROOT_PATH . '/inc/UploadPlus.inc.php';
require_once ROOT_PATH . '/inc/format_array_to_string.inc.php';

require_once ROOT_PATH . '/inc/excel/reader.php';
require_once ROOT_PATH . '/inc/Classes/PHPExcel.php';

require_once ROOT_PATH . '/inc/dump.inc.php';



