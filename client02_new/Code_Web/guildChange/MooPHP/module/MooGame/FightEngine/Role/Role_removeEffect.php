<?php
class Mod_MooGame_FightEngine_Role_removeEffect {
	/**
	 * 移除效果
	 * @param $effect
	 */
	function removeEffect($uniqueId, $magicRemove = 0, $actionOrder = 0) {
		if ($this->MOD->effect[$uniqueId]->timeOut == -1) {
			return;
		}
		$this->MOD->effect[$uniqueId]->remove($magicRemove, $actionOrder);
		unset($this->MOD->effect[$uniqueId]);
	}
}