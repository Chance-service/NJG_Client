<?php
class Mod_MooGame_FightEngine_Role_changeTrap {

	/**
	 * 陷阱
	 */
	function changeTrap($num) {
		
		$this->MOD->trap += $num;
		
		$this->MOD->trap < 0 && $this->MOD->trap = 0;

		return true;
	}
}