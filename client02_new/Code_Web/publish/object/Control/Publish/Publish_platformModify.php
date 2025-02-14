<?php
class Control_Publish_platformModify {

	function platformModify() {
		
		$returnData = array();
		$returnData['code'] = 0;
		
		$type = MooForm::request('type');
		$rs = MooObj::get('Publish')->platformModify();
		if (!$rs) {
			if ($type == 'del') {
				$returnData['msg'] = '删除失败！';
			} else {
				$returnData['msg'] = '修改失败！';
			}
			
			$this->OBJ->showMessage($returnData);
		}
		
		$returnData['code'] = 1;
		if ($type == 'del') {
			$returnData['msg'] = '删除成功！';
		} else {
			$returnData['msg'] = '修改成功！';
		}
		$this->OBJ->showMessage($returnData);
	}
}