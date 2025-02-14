<?php
class Mod_MooGame_FightEngine_Role_changeGroup {
	/**
	 * 改变角色所在方
	 */
	function changeGroup() {
		// 对方是英雄，则不允许变心
		if ($this->MOD->isHero) {
			return false;
		}
		
		// 对方只剩一个战士的时候不允许变心。
		if (count(Mod_MooGame_FightEngine_Control::${$this->MOD->group}) <= 1) {
			return false;
		}
		
		
		if ($this->MOD->group == 'attacker') {
			$this->MOD->group = 'defender';
			
			// 将角色放到对应的组里
			Mod_MooGame_FightEngine_Control::$defender[$this->MOD->id] = $this->MOD;
			
			// 从原组中删除掉该角色
			unset(Mod_MooGame_FightEngine_Control::$attacker[$this->MOD->id]);
		} else {
			$this->MOD->group = 'attacker';
			
			// 将角色放到对应的组里
			Mod_MooGame_FightEngine_Control::$attacker[$this->MOD->id] = $this->MOD;
			
			// 从原组中删除掉该角色
			unset(Mod_MooGame_FightEngine_Control::$defender[$this->MOD->id]);
		}
		return true;
	}
}