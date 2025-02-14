<?php
require_once 'common.php';

error_reporting(0);

// 生成龙珠数据库配置文件
MooObj::get('Control_ExcelConfMaker')->makeLzSqlConf();
