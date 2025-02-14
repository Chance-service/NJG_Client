<?php
class Mod_MooGame_FightEngine_Role_changeWhiteTiger {

	/**
	 * 白虎
	 */
	function changeWhiteTiger($num) {
		
		$this->MOD->whiteTiger += $num;

		return true;
	}
}