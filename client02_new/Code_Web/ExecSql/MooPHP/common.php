<?php
// 定义项目路径(默认为moophp外的目录)
!defined('ROOT_PATH')	&& define('ROOT_PATH', dirname(dirname(__FILE__)));

// 设置模块类(MooModule)的所在目录  (向前兼容)
!defined('LIB_PATH')	&& define('LIB_PATH', dirname(__FILE__) . '/lib');

require_once dirname(__FILE__) . '/lib/config.inc.php';
