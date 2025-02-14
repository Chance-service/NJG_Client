<?php
class Mod_MooGame_FightEngine_Role_changeAddict {

	/**
	 * 改变角色是否可以魅惑
	 */
	function changeAddict($num) {

		$this->MOD->addict += $num;

		$this->MOD->addict < 0 && $this->MOD->addict = 0;

		return true;
	}
}