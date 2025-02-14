<?php
class Mod_MooGame_FightEngine_Magic extends Mod_MooGame_FightEngine {
	public $id;				// 魔法ID
	public $roleId;			// 魔法所属的角色ID
	public $consumeMp;		// 魔法消耗的MP
	public $magicName;		// 魔法名称
	public $delMinHpMagic = 0;	// 是否是打对方血量最少将的魔法
	public $magicAim;		// 魔法作用目标
	public $magicAimNum	= 1;// 魔法作用目标数量
	public $magicAimRow = 0;// 魔法作用目标排数，默认按普攻规则打， 1:2,2:2为打第一排和第二排随机2个，1,2和魔法作用目标数量一起为打第一和第二排所有人的随机目标数 （0按普攻规则打，1第一排，2第二排，3第三排）
	public $magicAimRowRate = 100; // 当为打第一和第二排所有人的随机目标数时每个人成功的几率
	public $magicOdds;		// 魔法触发的几率
	public $magicCD;		// 魔法CD回合数
	public $magicLastTurn;	// 魔法上次使用回合
	public $magicMaxUseNum = -1;// 魔法最大使用次数
	public $magicUseNum;		// 魔法当前使用次数
	public $effect = array();	// 魔法对应的效果
	public $magicRemove;		// 魔法消失条件

	// 施法目标
	const MAGIC_AIM_SELF	= 1; // 只对自己起作用
	const MAGIC_AIM_GROUP	= 2; // 对己方起作用
	const MAGIC_AIM_ENEMY	= 3; // 对敌方起作用

	// 魔法消失
	const MAGIC_REMOVE_USE			= 1;
	const MAGIC_REMOVE_UNEFFECT		= 2;
	const MAGIC_REMOVE_ROUND_START	= 3;
}