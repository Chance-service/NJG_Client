<?php
class Control_Cdk_deleteCdk {
	function deleteCdk() {
		$cdk = MooForm::request('cdk');
		$cdkUrl = MooConfig::get('main.cdkUrl');
		$delCdkUrl = $cdkUrl . "/" . "del_cdk?" . "cdk=" . $cdk; 
		
		$res = MooUtil::curl_send($delCdkUrl);
		// 记录addCdk log 
		$result = MooJson::decode($res);
		
		if($result && $result['status'] == 0 && $result['cdks']) {
			$errMsg =  "删除cdk成功!";
			// 生成失败
			MooView::set('errorMsg1',$errMsg);
		} else {
			$errMsg = "该cdk已被删除或不存在!";
			// 生成失败
			MooView::set('errorMsg1',$errMsg);
		}
		MooView::render('operateCdk');
	}
}