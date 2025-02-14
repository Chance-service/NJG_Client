<?php
class Mod_MooGame_FightEngine_Role_changeChase {

	/**
	 * 追击
	 */
	function changeChase($num) {
		
		$this->MOD->chase += $num;
		
		$this->MOD->chase < 0 && $this->MOD->chase = 0;

		return true;
	}
}