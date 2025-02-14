<?php
class Mod_MooGame_FightEngine_Role_changeControl {

	/**
	 * 掌控
	 */
	function changeControl($num) {
		
		$this->MOD->control += $num;
		
		$this->MOD->control < 0 && $this->MOD->control = 0;

		return true;
	}
}