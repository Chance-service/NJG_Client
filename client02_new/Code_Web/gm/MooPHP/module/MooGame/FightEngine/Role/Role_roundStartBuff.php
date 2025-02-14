<?php
class Mod_MooGame_FightEngine_Role_roundStartBuff {

	/**
	 * 每个回合开始时，处理角色身上的buff
	 */
	function roundStartBuff() {
		// 取出所有效果
		foreach ((array)$this->MOD->effect as $effect) {
			// 判断效果是否永不过期
			if ($effect->timeOut != -1) {

				// 判断是否是回合前才需要去掉的到期效果
				if ($effect->magicRemove != Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START) {

					// 去掉已经到期的效果
					if ($this->MOD->lastActionRound - $effect->startTime >= $effect->timeOut) {
						$this->MOD->removeEffect($effect->uniqueId);
					}
					// 对回合开始魔法才消失做处理
				} elseif ($effect->magicRemove == Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START
					&& (Mod_MooGame_FightEngine_Control::$turnNum - $effect->startTime) > $effect->timeOut) {
						$this->MOD->removeEffect($effect->uniqueId, Mod_MooGame_FightEngine_Magic::MAGIC_REMOVE_ROUND_START);
						Mod_MooGame_FightEngine_Control::$ackNum++;
					}

			}

			// 判断是否为回合开始时触发的效果
			if (in_array(Mod_MooGame_FightEngine_Effect::TRIGGER_ROUND_START, (array)$effect->trigger)) {
				$effect->exec(Mod_MooGame_FightEngine_Effect::TRIGGER_ROUND_START);
			}
		}
		return true;
	}
}