<?php
class Mod_MooGame_FightEngine_Role_changeRebirth {

	/**
	 * 重生
	 */
	function changeRebirth($num, $hpRate) {
		
		$this->MOD->rebirth += $num;
		$this->MOD->rebirthHp += $hpRate;
		
		$this->MOD->rebirth < 0 && $this->MOD->rebirth = 0;
		$this->MOD->rebirthHp < 0 && $this->MOD->rebirthHp = 0;

		return true;
	}
}