<?php
class Control_Publish_addPlatform {

	function addPlatform() {
		
		$returnData = array();
		$returnData['code'] = 0;
		
		$platformTag = MooForm::request('platformTag');
		$platformName = MooForm::request('platformName');
		
		if (!$platformTag || !$platformName) {
			$returnData['msg'] = '请把信息填写完整！';
			$this->OBJ->showMessage($returnData);
		}
		
		$rs = MooObj::get('Publish')->addPlatform();
		if (!$rs) {
			$returnData['msg'] = '该平台已经存在！';
			$this->OBJ->showMessage($returnData);
		}
		
		$returnData['code'] = 1;
		$returnData['msg'] = '平台添加成功！';
		$this->OBJ->showMessage($returnData);
	}
}