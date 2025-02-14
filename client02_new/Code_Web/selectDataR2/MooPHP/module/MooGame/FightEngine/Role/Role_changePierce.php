<?php
class Mod_MooGame_FightEngine_Role_changePierce {

	/**
	 * 刺穿
	 */
	function changePierce($num) {
		
		$this->MOD->pierce += $num;

		return true;
	}
}