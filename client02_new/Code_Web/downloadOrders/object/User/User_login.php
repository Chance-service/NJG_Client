<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 登录
* $Id: User_login.php 290 2012-03-09 08:33:18Z lulu $
*/

class User_login {
	/**
	 * 取得用户信息
	 *
	 * @param  $request['userName']  用户名
	 * @param  $request['userPassword']  用户密码
	 * @return  void
	 */
	function login() {
		
		$returnData = array();
		$returnData['code'] = 0;

		$message = '';
		
		// 获取登录用户名 
		$userName = trim(MooForm::request('username'));
		$userPassword = trim(MooForm::request('password'));
		
		MooFile::write('login.log', $userName. "==" . $userPassword, true); 
		
		if (!$userName || !$userPassword) {
			$message = !$userName ? '用户名不能为空，请输入用户名' : '密码不能为空，请输入密码';
			$returnData['msg'] = $message;
			$this->OBJ->showMessage($returnData);
		}

		MooFile::write('login.log', "--1--", true);
		
		$user = MooObj::get('User')->getUser($userName, 'user_name');
		
		MooFile::write('login.log', "--2--", true);

		if (!$user) {
			$message ='您输入的用户名不存在，请重新输入！';
			$returnData['msg'] = $message;
			$this->OBJ->showMessage($returnData);
		}
		
		$md5pwd = md5($userPassword);
		
		MooFile::write('login.log', $user->user_password. "==" . $userPassword, true);
		
		if ($user->user_password != $md5pwd) {
			$message ='您输入的密码错误，请重新输入！';
			$returnData['msg'] = $message;
			$this->OBJ->showMessage($returnData);
		}

		MooSession::set('uId', $user->user_id);
		MooSession::set('name', $user->user_real_name );
		MooSession::set('time', time());
	
		
		MooFile::write('login.log', "--ok", true);
		
		$returnData['code'] = 1;
		$returnData['msg'] 	= "登录成功";
		
		
		exit(MooJson::encode($returnData));
	}

}