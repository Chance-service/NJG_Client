<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_add {
	/**
	 * 增加/编辑用户
	 *
	 * @param  $request['userName']  用户名
	 * @param  $request['userPassword']  用户密码
	 * @param  $request['userGroupId'] 用户组id
	 * @param  $request['userEditName']  需要编辑的用户名
	 * @param  $request['userEditPassword']  需要编辑的密码
	 * @param  $request['userEditGroupId']  需要编辑的用户组
	 * @param  $request['addSubmit']  是否为提交
	 * @return  void
	 */
	function add() {
	
		// 如果有提交  则会收到 添加用户 的用户名
		$loginName = MooForm::request('loginName');			// 用户名
		if($loginName) {
			$password 	= MooForm::request('password');		// 密码
			$name 		= MooForm::request('name');			// 用户姓名
			$gameIds	= MooForm::request('gameIds');		// 用户组id
			$role		= MooForm::request('role');			// 用户角色  1管理员  0普通用户
			
			$gameIds = substr($gameIds, 0, -1);
			
			$add = MooObj::get('User')->add($loginName, $password, $name, $gameIds, $role);
			$res = array();
			if (!$add) {
				$res['msg'] = "添加失败";
				$res['code'] = 0;
			} else {
				$res['msg'] = "添加成功";
				$res['code'] = 1;
			}
			
			echo MooJson::encode($res);	
			exit;
		} else {
			/*
			$url = "http://182.254.230.39:9001/fetch_game";
			
			$res = MooUtil::curl_send($url);
			
			$gameList = MooJson::decode($res, true);
			
			$gameList[2]['game'] = $gameList[2]['game'] . "	";
			*/
			
			$gameArr = MooConfig::get('main.game');
			
			$gameList[0]['game'] = $gameArr['0'];
			
			if ($gameList) {
				MooView::set('game', $gameList);
			}
				
			MooView::render('addUser');
		}

	}

}