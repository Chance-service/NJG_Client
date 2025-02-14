<?php

class User_getUserName {
	/**
	 * 取得用户name
	 *
	 */
	function getUserName() {
		$uId = MooObj::get('User')->verify();
		$user = MooObj::get('User')->getUser($uId);
		if(!$user) {
			return false;
		}
		$userName = $user->user_name;
		return $userName;
	}
}