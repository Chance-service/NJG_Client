<?php
require_once 'common.php';
ini_set('memory_limit',"1256M");
set_time_limit(MooConfig::get('main.timeLimit'));
// 静态文件url
MooView::set('staticUrl', MooConfig::get('main.staticUrl'));

// 设置显示全部状态
MooView::set('viewAll', MooConfig::get('main.viewAll'));	// 0 关闭 1 开启

$mod = MooForm::request('mod');
$do = MooForm::request('do');

// 获取用户信息
$uId = MooObj::get('User')->verify();

// 没有用户信息, 登录
if (!$uId) {
	MooObj::get('Control_User')->login();
}

MooObj::get('Control')->checkAction($mod, $do);

// 登录后 设置权限
MooObj::get('User_Group')->setPermit();

!$mod && $mod = 'Main';
!$do && $do = 'showIndex';
// 进行相关处理
MooObj::get('Control_' . $mod)->$do();

