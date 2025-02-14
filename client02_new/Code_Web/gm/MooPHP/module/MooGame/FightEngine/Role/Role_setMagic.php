<?php

class Mod_MooGame_FightEngine_Role_setMagic {
	/**
	 * 魔法使用
	 */
	function setMagic($magic) {
		$tmp = clone($magic);
		$tmp->roleId = $this->MOD->id;
		$this->MOD->magic[$tmp->id] = $tmp;
	}
}