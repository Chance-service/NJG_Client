<?php
class Mod_MooGame_PlatForm_Mobile_changeSex {

	public function changeSex($hashData, $sex) {

		$mobile = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['sex'] = $sex;

		$rs = $mobile->users('changeSex', $param);
		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Mobile_getVisitorInfo no data');
			return false;
		}
		
		return true;
	}
}
