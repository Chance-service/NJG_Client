<?php
class Mod_MooGame_FightEngine_Role_changeDragon {

	/**
	 * 青龙
	 */
	function changeDragon($num) {
		
		$this->MOD->dragon = $num;

		return true;
	}
}