<?php
class Mod_MooGame_FightEngine_Role_changePoison {

	/**
	 * 毒体
	 */
	function changePoison($num) {
		
		$this->MOD->poison += $num;
		
		$this->MOD->poison < 0 && $this->MOD->poison = 0;

		return true;
	}
}