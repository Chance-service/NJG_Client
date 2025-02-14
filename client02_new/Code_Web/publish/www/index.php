<?php
require_once 'common.php';

$game = MooConfig::get('game');

// 静态文件url
MooView::set('staticUrl', MooConfig::get('main.staticUrl'));

// 获取用户信息
$uId = MooObj::get('User')->verify();

// 没有用户信息, 登录
if (!$uId) {
	MooObj::get('Control_User')->login();
}

$mod = MooForm::request('mod');
$do = MooForm::request('do');

MooObj::get('Control')->checkAction($mod, $do);

// 登录后 设置权限
MooObj::get('User_Group')->setPermit();

!$mod && $mod = 'Main';
!$do && $do = 'showIndex';
// 进行相关处理
MooObj::get('Control_' . $mod)->$do();
