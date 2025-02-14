<?php

class Mod_MooGame_FightEngine_Role_setSpecialTreasureMagic {
	/**
	 * 特殊魔法使用
	 */
	function setSpecialTreasureMagic($magic) {
		$tmp = clone($magic);
		$tmp->roleId = $this->MOD->id;
		$this->MOD->specialTreasureMagic[$tmp->id] = $tmp;
	}
}