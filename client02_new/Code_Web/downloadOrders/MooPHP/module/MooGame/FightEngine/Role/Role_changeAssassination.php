<?php
class Mod_MooGame_FightEngine_Role_changeAssassination {

	/**
	 * 刺杀
	 */
	function changeAssassination($num) {
		
		$this->MOD->assassination = $num;

		return true;
	}
}