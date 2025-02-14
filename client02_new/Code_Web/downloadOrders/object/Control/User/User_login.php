<?php
class Control_User_login {
	/**
	 * 登录
	 *
	 * @param  $request['userName']  用户名
	 * @param  $request['password']  用户密码
	 * @return  void
	 */
	function login() {
		$username = MooForm::request("username");
		$password = MooForm::request('password');

		if ($username && $password) {
			MooObj::get('User')->login();
		} else {
			MooView::render('login');
		}
	}
}