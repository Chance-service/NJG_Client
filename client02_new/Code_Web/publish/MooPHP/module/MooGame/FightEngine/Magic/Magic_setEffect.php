<?php

class Mod_MooGame_FightEngine_Magic_setEffect {

	/**
	 * 设置魔法对应的效果
	 */
	function setEffect($effect) {
		$tmp = clone($effect);
		$tmp->magicId = $this->MOD->id;
		$tmp->magicUqId = $this->MOD->magicUqId;
		$tmp->magicName = $this->MOD->magicName;
		$tmp->magicRemove = $this->MOD->magicRemove;
		$tmp->magicAim = $this->MOD->magicAim;
		$tmp->magicAimNum = $this->MOD->magicAimNum;
		$this->MOD->effect[$tmp->id] = $tmp;
	}
}