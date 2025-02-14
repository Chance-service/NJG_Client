<?php
class User_verify {
	/**
	 * 验证用户
	 *
	 */
	function verify() {

		// 排除反复验证
		static $uId = null;

		if ($uId) {
			return $uId;
		}

		$uId = MooSession::get('uId');
		$lastLogin = MooSession::get('time');

		// 不存在uId
		if (!$uId) {
			return false;
		}

		// 时间过期
		if (time() - $lastLogin > MooConfig::get('user.loginExpire')) {
			$uId = null;
			MooSession::clear();
			return false;
		}

		$user = MooObj::get('User')->getUser($uId);

		// 用户不存在
		if (!$user) {
			$uId = null;
			return false;
		}

		return $uId;
	}
}