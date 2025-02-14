<?php
class Mod_MooGame_FightEngine_Role_changeBlew {

	/**
	 * 自爆
	 */
	function changeBlew($num) {
		
		$this->MOD->blew += $num;
		
		$this->MOD->blew < 0 && $this->MOD->blew = 0;

		return true;
	}
}