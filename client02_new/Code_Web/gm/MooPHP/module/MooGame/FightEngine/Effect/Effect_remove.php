<?php
class Mod_MooGame_FightEngine_Effect_remove {
	/**
	 * 移除效果
	 * 
	 * @param $actionOrder 0为出手后移除，1为出手前移除
	 * @param $effect
	 */
	function remove($magicRemove = 0, $actionOrder = 0) {

		$roleId = $this->MOD->beRoleId;

		// 取出角色
		$role = MooMod::get('MooGame_FightEngine_Control')->getAliveRole($roleId);

		// 如果角色不存在则直接返回
		if (!$role) {
			return true;
		}

		// 判断该效果是否需要移除
		if (!$this->MOD->effectRemove) {
			// 记录一个效果日志
			MooMod::get('MooGame_FightEngine_FightLog')->addUnBuffLog($this->MOD->execRoleId, $role->id, $this->MOD, $actionOrder);
			return true;
		}

		if ($this->MOD->effectByProps == 'harm') {
			return true;
		}

		// 修改指定数值
		if (!$magicRemove && $this->MOD->effectToProps != 'hp') {
			if ($this->MOD->effectToProps == 'atkHard') {
				$rs = $role->changeProps($this->MOD->effectToProps, -$this->MOD->effectTotalValue, $this->MOD, -$this->MOD->atkHardHarmRate);
			} else {
				$rs = $role->changeProps($this->MOD->effectToProps, -$this->MOD->effectTotalValue, $this->MOD);
			}
		}

		// 记录一个效果日志
		MooMod::get('MooGame_FightEngine_FightLog')->addUnBuffLog($this->MOD->execRoleId, $role->id, $this->MOD, $actionOrder);
		return true;
	}
}