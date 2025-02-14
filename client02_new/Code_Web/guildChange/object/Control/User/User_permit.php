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
			
		// 权限组名
		$permitName = MooForm::request('permitName');
		if($permitName) {
			// 权限数组 数据
			$permission = array();	
			$permitName = MooForm::request('permitName');	 	// 权限名称
			$manageUser = MooForm::request('manageUser');	 	// 权限管理 权限  1 | 0
			$manageBucket = MooForm::request('manageBucket');	// bucket 管理权限 1 | 0
			$backFile 	= MooForm::request('backFile');			// 回滚文件权限
			$permitDec = MooForm::request('permitDec');			// 添加备注
			
			$editPermit = MooForm::request('editPermit');		// 是否为编辑权限
			
			// 获取的是,隔开的
			$dirIds = MooForm::request('dirIds');				// 节点权限
			$dirIdsArr = array();
			if($dirIds) {
				$dirIds	= substr($dirIds, 0, -1);
				$dirIdsArr = explode(',', $dirIds);
			}
	
			$permission['manageUser'] 		= $manageUser;
			$permission['manageBucket']  	= $manageBucket;
			$permission['backFile']			= $backFile;
			$permission['nodePermit']		= $dirIdsArr;			
	
			// 权限内容
			$perData = MooJson::encode($permission);
			
			if ($editPermit && $editPermit == 1) {
				$groupId = 	MooForm::request('groupId');
				$dao = MooDao::get('Permit');
				$groupObj = $dao->load($groupId);
				if (!$groupObj) {
					$res['msg'] = "修改失败";
					$res['code'] = 0;
					echo MooJson::encode($res);	
					exit;
				}
				$groupObj->set('cp_name', $permitName);
				$groupObj->set('cp_permission', $perData);
				$groupObj->set('cp_desc', $permitDec);
				$res['msg'] = "修改成功";
				$res['code'] = 1;	
				echo MooJson::encode($res);	
				exit;
			} else {
				$dao = MooDao::get('Permit');
				$dao->setData('cp_name', $permitName);
				$dao->setData('cp_permission', $perData);
				$dao->setData('cp_desc', $permitDec);
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

			$dirAll = MooDao::get('Node')->getAll('select * from @TABLE where  node_type =:node_type order by bucket_id desc, node_id asc', array('node_type' => 0));
			$dirs = array();
			if (!$dirAll) {
				MooView::render('permit');
			}
			
			foreach($dirAll  as  $key => $val) {
				$bucketName 	 = $this->getBucketNameById($val['bucket_id']);
				if($bucketName) {
					$oneNode = MooObj::get('Node')->getOneNode($val['node_id']);
					$parentNodeId = $oneNode->node_parent_node;
					if ($parentNodeId == 0) {
						$res['node_id'] = $val['node_id'];					
						$res['bucket_id'] = $val['bucket_id'];
						$res['node_name'] = $val['node_name'];
						
						$res['bucket_name'] = $bucketName;
						$res['node_path'] = $bucketName . $this->getPathDir($val['node_parent_node']) . $val['node_name'];
						$res['parent_node_name'] = $this->getParentDirName($val['node_parent_node']);
						$dirs[] = $res;
					}
				}
			}
			
			MooView::set('dirs', $dirs);
			MooView::render('permit');
		}

	}
function getPathDir($nodeParentId){
	if ($nodeParentId == 0) {
		$path = '/' . $path;
	} else {			
		$parentNode = MooObj::get('Node')->getOneNode($nodeParentId);
		$path =   '/'. $parentNode->node_name . '/' . $path;
		if ($parentNode->node_parent_node != 0) {
			$this->getPathDir($parentNode->node_parent_node);
		}
	}	
	return $path;
}

function getParentDirName($node_id) {
	$node = MooObj::get('Node')->getOneNode($node_id);
	if (!$node) {
		return '/';
	}
	return $node->node_name;
}

function getBucketNameById($bucketId){
	$bucket = MooObj::get('Bucket')->getOneBucket($bucketId);
	if (!$bucket) {
		return false;
	}
	return $bucket->bucket_name;
}	
	
}
