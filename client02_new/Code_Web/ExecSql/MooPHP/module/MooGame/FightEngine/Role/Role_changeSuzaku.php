<?php
class Mod_MooGame_FightEngine_Role_changeSuzaku {

	/**
	 * 朱雀
	 */
	function changeSuzaku($num, $harmRate) {
		
		$this->MOD->suzaku += $num;
		$this->MOD->suzakuHarmRate += $harmRate;

		return true;
	}
}