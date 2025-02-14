<?php
class Mod_MooGame_FightEngine_Role_clearBeneficialEffect {
	/**
	 * 净化删除角色身上有益的效果
	 * @param $effect
	 */
	function clearBeneficialEffect() {

		// 判断当前角色身上是否有有益的效果
		if ($this->MOD->effect) {
			$skillConfig = MooConfig::get('skill');
			foreach ($this->MOD->effect as $uniqueId => $effectObj) {
				if ($skillConfig['skill2Conf'][$effectObj->magicId] || $skillConfig['skill3Conf'][$effectObj->magicId]) {
					continue;
				}
				if ($effectObj->effectMinValue > 0 && $effectObj->effectMaxValue > 0 &&
					 !in_array($effectObj->effectToProps, array('unAttackAble', 'unMagicAble', 'unActionAble', 'magicImmune'))) {
					$this->MOD->removeEffect($uniqueId);
				}
			}
		}

		return true;
	}
}