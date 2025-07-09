local CONST = require("Battle.NewBattleConst")

NgBattleEffectManager = NgBattleEffectManager or { }

NgBattleEffectManager.FxSkinSetting = {
    --["NG_01001_FX1"] = {
    --    [CONST.ANI_ACT.ATTACK] = {
    --        triggerFn = function(chaNode)
    --            local scripe = require("Battle.NewSkill.Skill_10106")
    --            return scripe["canPlaySpFx"] and scripe:canPlaySpFx(chaNode)
    --        end,
    --        [true] = "01",
    --        [false] = "02",
    --    }
    --}
}

function NgBattleEffectManager_changeFxSkin(chaNode, fx, fileName, aniName)
    if not NgBattleEffectManager.FxSkinSetting[fileName] then
        return
    end
    if not NgBattleEffectManager.FxSkinSetting[fileName][aniName] then
        return
    end
    local skin = NgBattleEffectManager.FxSkinSetting[fileName][aniName][NgBattleEffectManager.FxSkinSetting[fileName][aniName].triggerFn(chaNode)]
    fx:setSkin(skin)
end