<?php
class Mod_MooGame_FightEngine_Role_changeSweepAway {

	/**
	 * 横扫
	 */
	function changeSweepAway($num) {
		
		$this->MOD->sweepAway = $num;

		return true;
	}
}