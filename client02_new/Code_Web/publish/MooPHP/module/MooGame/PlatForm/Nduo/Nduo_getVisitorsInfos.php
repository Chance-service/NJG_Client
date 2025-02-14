<?php
class Mod_MooGame_PlatForm_Nduo_getVisitorsInfos {

	public function getVisitorsInfos($hashData, $fields, $uids = '') {

		//note 用户uid为空的时候，查当前用户uid
		if(!$uids) {
			$uids = $hashData['platFormUid'];
		}

		//note 检查输入的uids是否带了平台的标记，相应的适应
		$platFormTag = '__' . $hashData['platForm'];

		$existsPlatFormTag = strpos($uids, $platFormTag) === false ? false : true;

		//note 去除我们自己增加的标记,去掉空格，空格会造成调用不正确,方可去平台调用
		$uids = str_replace(array($platFormTag, ' '), array('', ''), $uids);

		//note 构造参数，请求平台
		$param = array('uids' => $uids);
		$qoojoy = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['server_id'] = $hashData['serverId'];
		$rs = $qoojoy->friends('getMultiFriend', $param);

		if ($rs['status'] != 100) {
			$this->MOD->setMsg('getVisitorsInfos no return');
			return false;
		}

		//note 一个用户的时候是直接返回直接数据，多个用户为数组，我们统一拼接为数组即可
		$visitorsInfos = $data = array();
		$data = $rs['data']['friendList'];

		//note 去掉平台的 uid 字段， 格式化返回uId带有平台标记字段和不带标记字段为 platFormUid
		//note 以输入的uids中的某一个具体uid分别为返回数组的key，如果输入的uids含有平台标记，那么key也会含有平台标记
		//note 在外部使用返回数据的时候调用方法，例如 $visitorsInfos[$uid]['sex']
		foreach($data as $key => $userInfo) {

			$tempArr = array();
			$tempArr['uId'] = $userInfo['uid'] . $platFormTag;
			$tempArr['platFormUid'] = $userInfo['uid'];
			$tempArr['uMail'] = $userInfo['email'];
			$tempArr['uNowServer'] = $userInfo['nowServer'];
			$tempArr['uServer'] = $userInfo['server'];
			$tempArr['uScore'] = $userInfo['score'];

			//note 保持和getVisitorInfo接口返回的性别信息一致性
			if(isset($userInfo['sex'])) {
				$tempArr['uSex'] = $userInfo['sex'] ? 1 : 0;
			}
			$vsInfoKey = $existsPlatFormTag ? $tempArr['uId'] : $tempArr['platFormUid'];
			$visitorsInfos[$vsInfoKey] = $tempArr;
		}

		return $visitorsInfos;
	}
}
