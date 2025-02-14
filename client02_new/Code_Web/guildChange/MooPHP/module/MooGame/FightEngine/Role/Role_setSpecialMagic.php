<?php

class Mod_MooGame_FightEngine_Role_setSpecialMagic {
	/**
	 * 特殊魔法使用
	 */
	function setSpecialMagic($magic) {
		$tmp = clone($magic);
		$tmp->roleId = $this->MOD->id;
		$this->MOD->specialMagic[$tmp->id] = $tmp;
	}
}