<?php
class Mod_MooGame_PlatForm_Qoojoy_changeSex {

	public function changeSex($hashData, $sex) {

		$qoojoy = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['sex'] = $sex;

		$rs = $qoojoy->users('changeSex', $param);
		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Qoojoy_getVisitorInfo no data');
			return false;
		}
		
		return true;
	}
}
