<?php
class Mod_MooGame_PlatForm_Nduo_changeSex {

	public function changeSex($hashData, $sex) {

		$nduo = Mod_MooGame_PlatForm::$platFormLibObj;
		$param['session_key'] = $hashData['sessionId'];
		$param['sex'] = $sex;

		$rs = $nduo->users('changeSex', $param);
		if ($rs['status'] != 100) {
			$this->MOD->setMsg('Mod_MooGame_PlatForm_Nduo_getVisitorInfo no data');
			return false;
		}
		
		return true;
	}
}
