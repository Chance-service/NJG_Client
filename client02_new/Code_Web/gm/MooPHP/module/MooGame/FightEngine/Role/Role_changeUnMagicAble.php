<?php
class Mod_MooGame_FightEngine_Role_changeUnMagicAble {

	/**
	 * 改变角色是否可以发动魔法攻击
	 */
	function changeUnMagicAble($num) {

		$this->MOD->unMagicAble += $num;

		$this->MOD->unMagicAble < 0 && $this->MOD->unMagicAble = 0;

		return true;
	}
}