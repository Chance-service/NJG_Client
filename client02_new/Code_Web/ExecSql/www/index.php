<?php
require_once 'common.php';

// 静态文件url
MooView::set('staticUrl', MooConfig::get('main.staticUrl'));

$mod = MooForm::request('mod');
$do = MooForm::request('do');

MooObj::get('Control')->checkAction($mod, $do);

// 登录后 设置权限
//MooObj::get('User_Group')->setPermit();

!$mod && $mod = 'Main';
!$do && $do = 'showIndex';
// 进行相关处理
MooObj::get('Control_' . $mod)->$do();
