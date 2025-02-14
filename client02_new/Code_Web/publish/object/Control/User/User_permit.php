<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_permit {
	/**
	 * 添加权限分组
	 */
	function permit() {
		// 判断权限
		$permission	= MooObj::get('User')->getPermission();
		// 没有用户管理权限
		if($permission['manageUser'] != 1) {
			$message = "你没有操作权限!";
			MooView::set('msg', $message);
			MooView::render('permitError');
		}	

		// 权限组名
		$permitName = MooForm::request('permitName');
		if($permitName) {
			// 权限数组
			$permission = array();	
			$manageUser = MooForm::request('manageUser');	 	// 权限管理 
			$manageGame = MooForm::request('manageGame');	 	// 游戏管理
			$manageServer = MooForm::request('manageServer');	// 服务器管理
			$managePlatform = MooForm::request('managePlatform');//平台管理
			$openServer 	= MooForm::request('openServer');	// 开服停服
			$onlineCrontal 	= MooForm::request('online');		// 线上控制
			$permitDec = MooForm::request('permitDec');			// 添加备注
			
			// 获取的是,隔开的
			$serverIds = MooForm::request('serverList');			// 操作服权限		
			
			$gameList = MooObj::get('Publish')->getGameList();
			$gameNum  = count($gameList);
			$requestServerIds = "";
			for($i=0;  $i< $gameNum; $i++) {
				$requestServerIds .=  ",";
			}
			
			// 默认什么都不选 权限为所有服都有权限
			if ($serverIds == $requestServerIds) {
				$serverIdArr['isAll'] = 'all';
			} else {
				$serverIdArr['isAll'] = 'no';
				$serverIds	= substr($serverIds, 0, -1);				
			}
			$serverIdArr['ids'] = explode(',', $serverIds);
			$serverIdJson = MooJson::encode($serverIdArr);
			
			$permit = MooForm::request('permit');				// 权限 数据
			$perArr = array();
			$perArr =  explode(",",$permit);					// 权限数组 格式为 id_bata id_release 等
			// 删除最后一个 空的 
			$length = count($perArr);
			unset($perArr[$length - 1]);
			
			$perData = array();
			foreach ($perArr as $k => $val) {
				$rs = explode("_", $val);
				$gameId = $rs[0]; 	// 游戏id 1 2
				$per = $rs[1];		// per beta release
				$perData[$gameId][$per] = 1;
			}
			
			$permission['publish'] 			= $perData;
			$permission['manageUser']  	 	= $manageUser;
			$permission['manageGame']		= $manageGame;
			$permission['manageServer']		= $manageServer;
			$permission['managePlatform']	= $managePlatform;
			$permission['openServer']		= $openServer;
			$permission['onlineCrontal']		= $onlineCrontal;
						
			// 服务器权限
			$permission['serverIds'] 		= $serverIdJson;
			
			// 插入数据库
			$perData = json_encode($permission);
			
			// 判断是否是编辑 如果是编辑 值改变属性就行
			$editPermit = MooForm::request('editPermit');
			
			if ($editPermit && $editPermit == 1) {
				$groupId = 	MooForm::request('groupId');
				$dao = MooDao::get('Group');
				$groupObj = $dao->load($groupId);
				if (!$groupObj) {
					$res['msg'] = "修改失败";
					$res['code'] = 0;
					echo MooJson::encode($res);	
					exit;
				}
				$groupObj->set('group_name', $permitName);
				$groupObj->set('group_permission', $perData);
				$groupObj->set('group_dec', $permitDec);
				$res['msg'] = "修改成功";
				$res['code'] = 1;	
				echo MooJson::encode($res);	
				exit;
			} else {
				$dao = MooDao::get('Group');
				$dao->setData('group_name', $permitName);
				$dao->setData('group_permission', $perData);
				$dao->setData('group_dec', $permitDec);
				if (!$dao->insert(false)) {
					$res['msg'] = "添加失败";
					$res['code'] = 0;
				} else {
					$res['msg'] = "添加成功";
					$res['code'] = 1;
				}
				echo MooJson::encode($res);	
				exit;
			}

		} else {
			// 获取游戏ids
			$gameIds = MooObj::get('Publish')->getGameIds();
			foreach ($gameIds as $key => $gameId) {
				$treeDatas[$gameId] = MooObj::get('Publish')->getTreeDataByGameId($gameId);
			}			
			
			// treeDatas 包含多个游戏
			MooView::set('treeDatas', $treeDatas);	
			MooView::render('permit');
		}

	}

}