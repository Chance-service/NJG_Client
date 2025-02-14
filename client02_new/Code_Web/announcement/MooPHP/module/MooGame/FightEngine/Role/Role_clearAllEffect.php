<?php
class Mod_MooGame_FightEngine_Role_clearAllEffect {
	/**
	 * 净化删除角色身上所有的效果
	 * @param $effect
	 */
	function clearAllEffect() {

		// 判断当前角色身上是否有效果
		if ($this->MOD->effect) {
			$skillConfig = MooConfig::get('skill');
			foreach ($this->MOD->effect as $uniqueId => $effectObj) {
				if ($skillConfig['skill2Conf'][$effectObj->magicId] || $skillConfig['skill3Conf'][$effectObj->magicId]) {
					continue;
				}
				$this->MOD->removeEffect($uniqueId);
			}
		}
		return true;
	}
}