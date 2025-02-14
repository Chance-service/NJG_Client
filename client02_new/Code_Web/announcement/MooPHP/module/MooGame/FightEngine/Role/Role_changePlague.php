<?php
class Mod_MooGame_FightEngine_Role_changePlague {

	/**
	 * 瘟疫
	 */
	function changePlague($num) {
		
		$this->MOD->plague += $num;
		
		$this->MOD->plague < 0 && $this->MOD->plague = 0;

		return true;
	}
}