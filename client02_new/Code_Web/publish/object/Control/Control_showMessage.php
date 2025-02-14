<?php
class Control_showMessage {
	/**
	 * 提示信息
	 *
	 * @param  $message  提示内容
	 * @param  $url  跳转地址
	 * @return  $second  停留时间
	 */
	function showMessage($message, $user, $url = '', $second = 3) {

		// 直接跳转
		if ($url && !$second) {
			$uId = $user->user_id;
			$key = "login" . $uId;
			$session = MooSession::get($key);
			$uId 	= $session['uId'];
			$name 	= $session['name'];		
			$permission = $session['permission'];
			
			$group = MooObj::get('User_Group')->getGroup($user->user_power);
			// 权限定义			
			$primitArray = array('p1' => 10, 'p2' => 20, 'p3' => 30, 'p4' => 40);
			
			if ($group) {
			// 4种权限
				foreach ($group as $val) {
					if ($val == 10) {
						MooView::set('p1', $primitArray['p1']);
					}elseif ($val == 20) {
						MooView::set('p2', $primitArray['p2']);
					} elseif ($val == 30) {
						MooView::set('p3', $primitArray['p3']);
					} elseif ($val == 40) {
						MooView::set('p4', $primitArray['p4']);
					}
				}
			}
			
			MooView::set('uId', $uId);
			MooView::set('name', $name);
			MooView::set('permission' ,$permission);
			MooView::render('index');
		}

		MooView::set('redirectUrl', $url);
		MooView::set('redirectTime', $second);
		MooView::set('message', $message);
		MooView::render('login2');
		exit();
	}

}