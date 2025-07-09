local thisPageName = "BattleStartChallange"
local CONST = require("Battle.NewBattleConst")
local BattleStartChallange = {}

local option = {
    ccbiFile = "BattleStageStart.ccbi",
    handlerMap =
    {
    },
    opcodes =
    {
    }
}

function BattleStartChallange:onAnimationDone(container)
    local NgFightSceneHelper = require("Battle.NgFightSceneHelper")
	local animationName = tostring(container:getCurAnimationDoneName())
	if animationName == "Untitled Timeline" then
        NgFightSceneHelper:EnterState(container, CONST.FIGHT_STATE.MOVING)
		BattleStartChallange:onClose(container)
	end
end

function BattleStartChallange:onLoad(container)
	container:loadCcbiFile(option.ccbiFile)
    local langType = CCUserDefault:sharedUserDefault():getIntegerForKey("LanguageType")
    local spineNode = container:getVarNode("mSpineNode")
    spineNode:setVisible(false)
    local spine = SpineContainer:create("Spine/NGUI", "NGUI_15_BattleStart")
    local sTonNode = tolua.cast(spine, "CCNode")
    spineNode:setScale(NodeHelper:getScaleProportion())
    spineNode:addChild(sTonNode)
    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
        spine:setSkin(langType)
        spine:runAnimation(1, "animations01", 0)
        spineNode:setVisible(true)
        require("TransScenePopUp")
        TransScenePopUp_closePage()
        BattleStartChallange:playAnimation(container)
    end))
    array:addObject(CCDelayTime:create(2))
    array:addObject(CCCallFunc:create(function()
        CONST.IS_BATTLE_NEXT = false
    end))
    spineNode:runAction(CCSequence:create(array))
end

function BattleStartChallange:onClose(container)
    PageManager.popPage(thisPageName)
end

function BattleStartChallange:playAnimation(container)
    container:runAnimation("Untitled Timeline")
end

----------------------------------------------------------------------------------
local CommonPage = require("CommonPage")
local ActPage = CommonPage.newSub(BattleStartChallange, thisPageName, option)

return ActPage