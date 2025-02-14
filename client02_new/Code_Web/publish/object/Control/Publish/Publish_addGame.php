<?php
class Control_Publish_addGame {

	function addGame() {
		
		$returnData = array();
		$returnData['code'] = 0;
		
		$gameTag = MooForm::request('gameTag');
		$gameName = MooForm::request('gameName');
		$checkoutUrl = MooForm::request('checkoutUrl');
		$svnUserName = MooForm::request('svnUserName');
		$svnPassword = MooForm::request('svnPassword');
		
		if (!$gameTag || !$gameName || !$checkoutUrl || !$svnUserName || !$svnPassword) {
			$returnData['msg'] = '请把信息填写完整！';
			$this->OBJ->showMessage($returnData);
		}
		
		$rs = MooObj::get('Publish')->addGame();
		if (!$rs) {
			$returnData['msg'] = '该游戏已经存在！';
			$this->OBJ->showMessage($returnData);
		}
		
		$returnData['code'] = 1;
		$returnData['msg'] = '游戏添加成功！';
		$this->OBJ->showMessage($returnData);
	}
}