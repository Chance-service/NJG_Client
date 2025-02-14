<?php
class Control_Publish_addServer {

	function addServer() {
		
		$returnData = array();
		$returnData['code'] = 0;
		
		$gameId = MooForm::request('gameId');
		$platforms = MooForm::request('platforms');
		$serverTag = MooForm::request('serverTag');
		$serverName = MooForm::request('serverName');
		$version = MooForm::request('version');
		$onlineServerDir = MooForm::request('onlineServerDir');
		$serverIp = MooForm::request('serverIp');
		$serverUser = MooForm::request('serverUser');
		$sshPort = MooForm::request('sshPort');
		
		if (!$gameId || !$platforms || !$serverTag || !$serverName || !$version || !$onlineServerDir || !$serverIp || !$serverUser || !$sshPort) {
			$returnData['msg'] = '请把信息填写完整！';
			$this->OBJ->showMessage($returnData);
		}
		
		$rs = MooObj::get('Publish')->addServer();
		if (!$rs) {
			$returnData['msg'] = '添加失败！';
			$this->OBJ->showMessage($returnData);
		}
		
		$returnData['code'] = 1;
		$returnData['msg'] = '添加成功！';
		$this->OBJ->showMessage($returnData);
	}
}