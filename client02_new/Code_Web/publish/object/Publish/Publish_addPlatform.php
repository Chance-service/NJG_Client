<?php
class Publish_addPlatform {

	function addPlatform() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['managePlatform'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}
		$platformTag = MooForm::request('platformTag');
		$platformName = MooForm::request('platformName');
		
		$platformDao = MooDao::get('Platform');
		$platformObj = $platformDao->load(array('pl_tag' => $platformTag));
		if ($platformObj) {
			return false;
		}
		
		$platformDao->setData('pl_tag', $platformTag);
		$platformDao->setData('pl_name', $platformName);
		$platformDao->setData('pl_time', time());
		$platformDao->insert();

		return true;
	}
}