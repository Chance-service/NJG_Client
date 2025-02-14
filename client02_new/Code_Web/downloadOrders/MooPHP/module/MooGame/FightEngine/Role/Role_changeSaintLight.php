<?php
class Mod_MooGame_FightEngine_Role_changeSaintLight {

	/**
	 * 圣光
	 */
	function changeSaintLight($num) {
		
		$this->MOD->saintLight += $num;
		
		$this->MOD->saintLight < 0 && $this->MOD->saintLight = 0;

		return true;
	}
}