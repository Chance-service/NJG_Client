<?php
class Mod_MooGame_FightEngine_Role_changeBloodthirsty {

	/**
	 * 嗜血
	 */
	function changeBloodthirsty($num) {
		
		$this->MOD->bloodthirsty = $num;
		$this->MOD->atk += $this->MOD->def;
		$this->MOD->initAtk = $this->MOD->atk;
		$this->MOD->def = 0;
		$this->MOD->initDef = 0;

		return true;
	}
}