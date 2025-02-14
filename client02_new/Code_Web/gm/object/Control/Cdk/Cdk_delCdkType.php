<?php
class Control_Cdk_delCdkType {
	function delCdkType() {
		$game = MooForm::request('game');
		$type = MooForm::request('cdkType');
		$cdkUrl = MooConfig::get('main.cdkUrl');
		$delCdkTypeUrl = $cdkUrl . "/" . "del_type?" . "game=" . $game . "&type=" . $type; 
		
		$res = MooUtil::curl_send($delCdkTypeUrl);
		// 记录addCdk log 
		$result = MooJson::decode($res);
		
		if($result && $result['status'] == 0) {
			$errMsg =  "删除成功!";
			// 生成失败
			MooView::set('errorMsg2',$errMsg);
		} else {
			$errMsg = "该cdk类型 不存在!";
			// 生成失败
			MooView::set('errorMsg2',$errMsg);
		}
		MooView::render('operateCdk');
	}
}