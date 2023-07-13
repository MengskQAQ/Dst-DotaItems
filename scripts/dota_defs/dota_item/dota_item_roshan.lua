local dota_item_roshan = {}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------肉山--------------------------------------------------
--------------------------------------------------------------------------------------------------------

-------------------------------------------------不朽之守护-------------------------------------------------
dota_item_roshan.dota_aegis_of_the_immortal = {
    name = "dota_aegis",
    animname = "dota_aegis",
	animzip = "dota_roshan", 
	taglist = {
    },
    -- mengsk_dota2_sounds/items/aegis_expire -- 时间到
    -- mengsk_dota2_sounds/items/aegis_timer -- 复活时
}
-------------------------------------------------奶酪-------------------------------------------------
dota_item_roshan.dota_cheese = {
    name = "dota_cheese",
    animname = "dota_cheese",
	animzip = "dota_roshan", 
    extrafn=function(inst)
        -- inst:AddComponent("edible")
        -- inst.components.edible.foodtype = FOODTYPE.SEEDS
        -- inst.components.edible.healthvalue = TUNING.DOTA.CHEESE.HEALTH
        -- inst.components.edible.hungervalue = TUNING.DOTA.CHEESE.MANA
    end
}
-------------------------------------------------刷新球碎片-------------------------------------------------
dota_item_roshan.dota_refresher_shard = {
    name = "dota_refresher_shard",
    animname = "dota_refresher_shard",
	animzip = "dota_roshan", 
	taglist = {
    },
}
return {dota_item_roshan = dota_item_roshan}