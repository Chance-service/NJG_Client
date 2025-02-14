<?php
class Mod_MooGame_FightEngine_Role_changeWill {

	/**
	 * 重生
	 */
	function changeWill($num) {
		
		$this->MOD->will += $num;
		
		$this->MOD->will < 0 && $this->MOD->will = 0;

		return true;
	}
}