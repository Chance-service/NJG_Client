<?php
class Mod_MooGame_FightEngine_Role_changeProps {

	function changeProps($props, $value, $effect = '', $atkHardHarmRate = 0, $noLog = 0) {

		// 判断当前对战者是否已经死亡
		if ($this->MOD->group == 'attacker' && !Mod_MooGame_FightEngine_Control::$attacker[$this->MOD->id]) {
			return array();
		} elseif ($this->MOD->group == 'defender' && !Mod_MooGame_FightEngine_Control::$defender[$this->MOD->id]) {
			return array();
		}

		$v1 = $this->MOD->$props;

		$func = 'change' . ucwords($props);
		if ($func == 'changeHpMax') {
			$rs = $this->MOD->$func($value, $noLog);
		} elseif ($func == 'changeShield' && $effect) {
			$rs = $this->MOD->$func($value, $effect);
		} elseif ($atkHardHarmRate) {
			$rs = $this->MOD->$func($value, $atkHardHarmRate);
		} else {
			$rs = $this->MOD->$func($value);
		}

		$this->addChangeLog($props, $v1, $this->MOD->$props, $effect);

		if (!$rs) {
			return array();
		}
		
		if ($value > 0 && $props == 'hp' && ($this->MOD->$props - $v1) == 0) {
			return array('change' => $value);
		} else {
			return array('change' => $this->MOD->$props - $v1);
		}
	}

	function addChangeLog($props, $v1, $v2, $effect) {

		$log['roleId'] = $this->MOD->id;
		$log['props'] = $props;
		$log['fromValue'] = $v1;
		$log['toValue'] = $v2;
		if ($props == 'hp') {
			$log['atkHard'] = Mod_MooGame_FightEngine_Control::$isAtkHard ? 1: 0;
		}
		if ($props == 'shield') {
			$log['shieldEffectId'] = $this->MOD->shieldEffectId;
			$log['shieldUniqueId'] = $this->MOD->shieldUniqueId;
		}
		if ($effect) {
			$log['effectId'] = $effect->id;
			$log['uniqueId'] = $effect->uniqueId;
		}

		$this->MOD->propsChangeLog[] = $log;
	}
}
