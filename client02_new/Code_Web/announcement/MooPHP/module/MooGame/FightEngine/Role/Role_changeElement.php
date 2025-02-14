<?php
class Mod_MooGame_FightEngine_Role_changeElement {

	/**
	 * 元素
	 */
	function changeElement($num) {
		
		$this->MOD->element += $num;
		
		$this->MOD->element < 0 && $this->MOD->element = 0;

		return true;
	}
}