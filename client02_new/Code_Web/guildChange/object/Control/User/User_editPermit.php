<?php
/*
* More & Original PHP Framwork
* Copyright (c) 2009 - 2010 IsMole Inc.
* project svn自动发布系统
* document 增加/编辑用户
* $Id: User_add.php 179 2011-05-13 03:14:05Z lulu $
*/

class Control_User_editPermit {
	/*
	 * 管理用户权限
	 */
	function editPermit() {

		$groupId = MooForm::request('groupId');
		$dao = MooDao::get('Permit');
		$group = $dao->load($groupId);
		
		if(!$group) {
			return false;
		}
		
		$permissionName = $group->cp_name;
		$permissionJson = $group->cp_permission;
		$permissionDesc = $group->cp_desc;
		$permissionArr  = json_decode($permissionJson, true);
	
		// 修改与新增区别
		$editPermit	= 1;
		$manageUser 	= $permissionArr['manageUser'];
		$manageBucket 	= $permissionArr['manageBucket'];
		$backFile 		= $permissionArr['backFile'];
		
		$nodePermit     = $permissionArr['nodePermit'];
		
		// 设置权限状态zhi
		MooView::set('groupId', $groupId);	
		MooView::set('groupName', $permissionName);
		MooView::set('groupDesc', $permissionDesc); // 备注
		
		// 设置编辑
		MooView::set('editPermit', $editPermit);
		
		MooView::set('managePermit', $manageUser);
		MooView::set('manageBucket', $manageBucket);
		MooView::set('backFile', $backFile);
		
		
		$dirAll = MooDao::get('Node')->getAll('select * from @TABLE where  node_type =:node_type order by bucket_id desc, node_id asc', array('node_type' => 0));
		$dirs = array();
		if (!$dirAll) {
			 MooView::render('editPermit');
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
					
					if ($nodePermit) {
						$res['isHas'] = in_array($res['node_id'], $nodePermit) ? 1 : 0;
					}
					$dirs[] = $res;
				}
			}
		}
		
		MooView::set('dirs', $dirs);
		
		MooView::render('editPermit');
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
