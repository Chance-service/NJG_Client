<?php
class Mod_MooGame_FightEngine_Effect extends Mod_MooGame_FightEngine {
	public $id;
	public $effectName;					// 效果名称
	public $trigger = array();			// 生效条件
	public $effectAim;					// 作用目标
	public $effectAimGroup;				// 作用目标群体
	public $effectConfusion = 0;		// 是否是混乱效果
	public $effectMaxValue;				// 作用最大值
	public $effectMinValue;				// 作用最小值
	public $effectByRole;				// 借鉴我方或者对方的角色来增加属性
	public $effectByProps;				// 根据什么属性来改变
	public $effectToProps;				// 改变什么属性
	public $atkHardHarmRate;			// 暴击伤害倍率
	public $timeOut;					// 有效的回合数
	public $specialEffectId;			// 特殊效果ID（从效果库调取）
	public $effectRemove		= false;// 效果结束的时候是否移除已经产生的效果
	public $effectValueReplace	= false;// 数值改变模式：直接赋值、计算（默认）
	public $effectRate			= 100;	// 效果触发的概率
	public $buffRate			= 100;	// buff触发的概率
	public $buffId;						// buff的id
	public $buffRepalce			= false;// 判断buff是否是覆盖关系，若相同的buff已存在，则覆盖之前的回合数
	public $isCover				= false;// 是否是覆盖之前产生的效果
	public $haveAnimation		= 0;	// 是否有效果动画，默认没有

	public $uniqueId;				// 效果唯一的id
	public $magicId = 0;			// 效果所属魔法的ID
	public $magicName;				// 效果所属魔法的名称
	public $magicAim;				// 魔法作用目标
	public $magicAimNum		= 1;	// 魔法作用目标数量
	public $execRoleId;				// 施法者ID
	public $atRoleId;				// 效果当前所在角色ID
	public $beRoleId;				// 被施法者ID
	public $effectRealValue;		// 实际作用值
	public $effectTotalValue;		// 累计作用值
	public $effectTotalValueCopy;	// 累计作用值的备份
	public $startTime;				// 效果开始时的回合数
	public $buffRealValue;			// 实际作用的buff值

	public $lastTimeHarm;				// 存储每次被施法受到的伤害

	// 生效条件
	const TRIGGER_FIGHT			= 1;	// 进攻时触发
	const TRIGGER_FIGHT_ATK		= 2;	// 物理进攻时触发
	const TRIGGER_FIGHT_MAGIC	= 3;	// 魔法进攻时触发
	const TRIGGER_DEFEND		= 4;	// 防御时触发
	const TRIGGER_DEFEND_ATK	= 5;	// 物理防御时触发
	const TRIGGER_DEFEND_MAGIC	= 6;	// 魔法防御时触发
	const TRIGGER_MAGIC_USE		= 7;	// 魔法使用时触发
	const TRIGGER_ROUND_START	= 8;	// 回合开始时触发
	const TRIGGER_FIGHT_AFTER	= 9;	// 进攻后触发

	// 效果作用目标
	const EFFECT_AIM_SELF		= 1;	// 作用于自己
	const EFFECT_AIM_ENEMY		= 2;	// 作用于敌方
	const EFFECT_AIM_BOTH		= 3;	// 作用于双方
	const EFFECT_AIM_FRIEND		= 4;	// 作用于己方

	// 效果作用目标群体
	const EFFECT_AIM_GROUP_ALLSELF		= 1;	// 作用于己方全体
	const EFFECT_AIM_GROUP_ALLENEMY		= 2;	// 作用于敌方全体

	// 效果借鉴方
	const EFFECT_BY_ROLE_SELF	= 1;	// 借鉴自己
	const EFFECT_BY_ROLE_AIM	= 2;	// 借鉴目标

}