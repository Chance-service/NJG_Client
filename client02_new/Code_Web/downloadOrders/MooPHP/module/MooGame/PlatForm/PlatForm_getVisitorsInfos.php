<?php
class Mod_MooGame_PlatForm_getVisitorsInfos {
	/**
	 * 返回多个用户的各种信息，或者单个用户的指定字段信息
	 *
	 * @param string $fields 返回的字段列表，可以指定返回那些字段，用逗号分隔。
	 * @param string $uids 需要查询的用户的id，用逗号分隔，不传参数的时候为当前用户id, 可以带平台标记，也可以不带
	 * @return array $visitorsInfos 数据格式例如下面， 调用某一个人的某一个字段值 $visitorsInfos[$uid]['uSex']。
		uId, platFormUid为固定会返回，当有查性别字段sex时候会被格式统一返回为 uSex
		Array
		(
		    [101637452__XN] => Array
			(
			    [star] => 1
			    [mainurl] => http://hdn.xnimg.cn/photos/hdn321/20091005/1505/main_jBOy_9797c019117.jpg
			    [uId] => 101637452__XN
			    [platFormUid] => 101637452
			    [uSex] => MALE
			)

		    [315449911__XN] => Array
			(
			    [star] => 0
			    [mainurl] => http://hdn.xnimg.cn/photos/hdn321/20100225/0940/h_main_Z29E_31b200012c242f75.jpg
			    [uId] => 315449911__XN
			    [platFormUid] => 315449911
			    [uSex] => MALE
			)

		)
	 */
	function getVisitorsInfos($fields, $uids = '') {
		$hashData = MooMod::get('MooGame_PlatForm')->getHash();
		if (!$hashData) {
			$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
			return false;
		}

		if ($hashData['useOS'] === 'TRUE') {
			$data = $this->runOS($hashData, $fields, $uids);
		} else {
			$data = $this->runF8($hashData, $fields, $uids);
		}

		return $data;
	}

	function runOS($hashData, $fields, $uids) {
		return MooMod::get('MooGame_PlatForm_OpenSocial')->getVisitorInfo($hashData, $fields, $uids);
	}

	function runF8($hashData, $fields, $uids) {
		switch ($hashData['platForm']) {
			case 'MY' :
				$platForm = 'Manyou';
				$uPicField = 'pic_thumb';
				$uNameField = 'name';
				$uVipField = '';
				break;
			case 'XN' :
				$platForm = 'Renren';
				$uPicField = 'headurl';
				$uNameField = 'name';
				$uVipField = 'zidou';
				break;
			case '51' :
				$platForm = 'Com51';
				$uPicField = 'face';
				$uNameField = 'username';
				$uVipField = 'vip';
				break;
			case 'DE' :
				$platForm = 'Debug';
				$uPicField = 'headurl';
				$uNameField = 'username';//*
				$uVipField = '';
				break;
			case 'BAI' :
				$platForm = 'Baishehui';
				$uPicField = 'pic_small';
				$uNameField = 'uname';
				$uVipField = '';
				break;
			case 'FB' :
				$platForm = 'Facebook';
				$uPicField = 'headurl';
				$uNameField = 'username';
				$uVipField = '';
				break;
			case 'BD' :
				$platForm = 'Baidu';
				$uPicField = 'portrait';
				$uNameField = 'username';
				$uVipField = '';
				break;
			case 'MS' :
				$platForm = 'Myspace';
				$uPicField = 'pic';
				$uNameField = 'name';
				$uVipField = '';
				break;
			case '360' :
				$platForm = 'Com360';
				$uPicField = 'headurl';
				$uNameField = 'name';
				$uVipField = '';
				break;
			case '139' :
				$platForm = 'Com139';
				$uPicField = 'middleurl';
				$uNameField = 'username';
				$uVipField = '';
				break;
			case 'Studivz' :
				$platForm = 'Studivz';
				$uPicField = 'uPic';
				$uNameField = 'uName';
				$uVipField = 'uVip';
				break;
			case 'KX' :
				$platForm = 'Kaixin001';
				$uPicField = 'logo50';
				$uNameField = 'name';
				$uVipField = '';
				break;
			case 'IS' :
				$platForm = 'IsMole';
				$uPicField = 'pic';
				$uNameField = 'name';
				$uVipField = '';
				break;
			case 'QD' :
				$platForm = 'Qidian';
				$uPicField = 'tinyurl';
				$uNameField = 'name';
				$uVipField = 'zidou';
				break;
			case 'MX' :
				$platForm = 'Mixi';
				$uPicField = 'pic';
				$uNameField = 'lastname';
				$uVipField = '';
				break;
			case 'CW' :
				$platForm 	= 'Cyworld';
				$uPicField 	= 'pic';
				$uNameField = 'lastname';
				$uVipField 	= '';
				break;
			case 'GL':
				$platForm 	= 'GonLine';
				break;
			case 'QM':
				$platForm = 'Qimi';
				$uPicField = 'uPic';
				$uNameField = 'uName';
				$uVipField = '';
				break;
			case 'QJ' :
				$platForm = 'Qoojoy';
				break;
			default :
				$this->MOD->setMsg(MooConfig::get('system.errorCode.errorRequest'));
				return array();
		}

		//note 增加统一的头像字段兼容，在无论任何平台的调用都是一致的 uPic
		$fields = str_replace('uPic', $uPicField, $fields);
		$fields = str_replace('uName', $uNameField, $fields);
		$fields = str_replace('uVip', $uVipField, $fields);

		if (!$data = MooMod::get('MooGame_PlatForm_' . $platForm)->getVisitorsInfos($hashData, $fields, $uids)) {
			return array();
		}

		//note 增加统一的头像字段兼容，在无论任何平台的调用都是一致的 uPic
		foreach($data as $reUid=>$val) {
			$val['uPic']	= $platForm != 'Baidu' ? $val[$uPicField] : 'http://tx.bdimg.com/sys/portrait/item/'.$val[$uPicField].'.jpg';
			$val['uName']	= $val[$uNameField];
			$val['uVip']	= $val[$uVipField];
			$data[$reUid]	= $val;
		}

		return $data;
	}
}
