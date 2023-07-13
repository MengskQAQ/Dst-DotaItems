local function OnCreateFn(inst, owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0, 0.2, 0)
    -- inst.Follower:FollowSymbol(self.inst.GUID, "swap_body", 0, 0, 0)
end

local dota_shield = {}

-------------------------------------------------洞察烟斗 or 笛子-------------------------------------------------
dota_shield.barrier = {
    name = "dota_shield_barrierfx",
    animzip = "forcefield",
    bank = "forcefield",
    build = "forcefield",
    anim = "open",
    loopanim = "idle_loop",
    killanim = "close",
    scale = Vector3(1, 1, 1),

    maxhealth = TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.MAGIC,
    duration = TUNING.DOTA.PIPE_OF_INSIGHT.BARRIER.DURATION,
    oncreatefn = OnCreateFn,
}
-------------------------------------------------挑战头巾-------------------------------------------------
dota_shield.insulation = {
    name = "dota_shield_insulationfx",
    animzip = "forcefield",
    bank = "forcefield",
    build = "forcefield",
    anim = "open",
    loopanim = "idle_loop",
    killanim = "close",

    maxhealth = TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.DAMAGE,
    duration = TUNING.DOTA.HOOD_OF_DEFIANCE.INSULATION.DURATION,
    oncreatefn = OnCreateFn,
}
-------------------------------------------------永世法衣-------------------------------------------------
local SHROUDDAMAGE = TUNING.DOTA.SHROUD.SHROUD.DAMAGE
dota_shield.shroud = {
    name = "dota_shield_shroudfx",
    animzip = "forcefield",
    bank = "forcefield",
    build = "forcefield",
    anim = "open",
    loopanim = "idle_loop",
    killanim = "close",

    maxhealth = TUNING.DOTA.SHROUD.SHROUD.DAMAGE,
    duration = TUNING.DOTA.SHROUD.SHROUD.DURATION,
    oncreatefn = OnCreateFn,
    ontakedamagefn = function(inst, owner, damage)
        if owner.components.dotaattributes ~= nil and damage < SHROUDDAMAGE then
            owner.components.dotaattributes:Mana_DoDelta(damage, nil, "dota_shroud")
        end
    end,
}

return dota_shield