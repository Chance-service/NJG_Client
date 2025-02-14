<?php
$CONF = array();

// 平台数据库配置
$CONF['publish']['host'] = 'localhost';
$CONF['publish']['user'] = 'root';
$CONF['publish']['pwd'] = '';
$CONF['publish']['dbName'] = 'lol_publish';
$CONF['publish']['char'] = 'utf8';
$CONF['publish']['prefix'] = 'lol_publish`.`lp_';

// 是否开启pconnect, 开启pconnect必须是使用表名为 'dev_amazingtrip_user`.`qj_' . $tableName 的查询方式
$CONF['connect']['pconnect'] = true;

/**
 * 在发查询的时候，是否需要选择 selectDb
 * 这个选项仅仅针对链接为pconnect为false时候起效
 * true 标识兼容老版本的写法，但消耗更多的链接资源
 * false 必须使用表名为 'dev_amazingtrip_user`.`qj_' . $tableName 的查询方式
 */
$CONF['connect']['selectDb'] = false;
