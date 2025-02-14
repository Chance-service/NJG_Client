<?php
class Mod_MooGame_FightEngine_Role_changeFirm {

	/**
	 * 坚定
	 */
	function changeFirm($num) {
		
		$this->MOD->firm += $num;
		
		$this->MOD->firm < 0 && $this->MOD->firm = 0;

		return true;
	}
}