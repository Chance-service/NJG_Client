<?php
class Mod_MooGame_FightEngine_Role_changeOddPoor {

	/**
	 * 穷奇
	 */
	function changeOddPoor($num) {
		
		$this->MOD->oddPoor += $num;
		
		$this->MOD->oddPoor < 0 && $this->MOD->oddPoor = 0;

		return true;
	}
}