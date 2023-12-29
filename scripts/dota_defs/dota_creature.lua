local creature = {
-- 蜘蛛
"spider","spider_warrior","spider_moon","spider_hider",
"spider_spitter","spider_dropper","spider_healer",
-- 猪人
"pigman","pigguard","moonpig","pigelitefighter1",
"pigelitefighter2","pigelitefighter3","pigelitefighter4",
"pigelite1","pigelite2","pigelite3","pigelite4",
-- 兔人
"bunnyman",
-- 鱼人
"merm","mermguard","mermking",
-- 海象
"walrus","little_walrus",
-- 海鲜
"wobster_sheller_land","wobster_moonglass_land","squid","shark",
"gnarwail","cookiecutter",
-- 鸟类
"robin","robin_winter","crow","canary","puffin","canary_poisoned","buzzard",
"smallbird","teenbird","tallbird","penguin","mutated_penguin",
-- 小生物
"rabbit","frog","perd","catcoon","mole","bat","lavae","gingerbreadpig",
"butterfly","moonbutterfly","mosquito","grassgekko","carrat","fruitdragon",
"mandrake_active","lightcrab",
-- 食人花
"lureplant","eyeplant",
-- 牛象鹿
"beefalo","babybeefalo","koalefant_summer","koalefant_winter","lightninggoat",
"deer","deer_red","deer_blue",
-- 触手
"tentacle","tentacle_pillar","tentacle_pillar_arm",
-- 坎普斯
"krampus",
-- 蜜蜂
"bee","killerbee","beeguard",
-- 齿轮怪
"knight","knight_nightmare","bishop","bishop_nightmare","rook","rook_nightmare",
-- 猎犬
"hound","icehound","firehound","mutatedhound","clayhound","moonhound",
-- 猴子
"monkey","powder_monkey","prime_mate",
-- 洞穴生物
"slurtle","snurtle","rocky","slurper","worm",
-- 鬼魂
"ghost",
-- 影怪
"crawlinghorror","crawlingnightmare","terrorbeak","nightmarebeak","oceanhorror",
"shadow_leech",
-- 树精
"leif","leif_sparse","birchnutdrake",
-- 跟随者/小宠物
"chester","hutch","glommer","abigail","lavae_pet","wobysmall","wobybig",
"shadowduelist","shadowminer","shadowlumber","shadowdigger",
-- 中型生物
"spat","mossling","beegurd","crabking_claw","stalker_minion","stalker_minion1",
"stalker_minion2","eyeturret",
-- 座狼
"warglet","claywarg","warg","gingerbreadwarg",
-- BOSS
"spiderqueen","moose","antlion","bearger","deerclops","dragonfly","shadow_bishop",
"beequeen","malbatross","klaus","crabking","toadstool","toadstool_dark",
"stalker","stalker_forest","stalker_atrium","shadow_knight","shadow_rook",
-- 永不妥协
"aphid","shockworm","vampirebat","viperworm","chimp","bush_crab",
"uncompromising_toad","uncompromising_rat","uncompromising_hounds",
"fruitbat","snapdragon","woodpecker","snowmong","stumpling","knook",
"bight","roship","lightninghound","magmahound","sporehound","rnehound",
"glacialhound","um_pawn","um_pawn_nightmare","pollenmites","um_scorpion",
"um_scorpion","spider_trapdoor","creepingfear","dreadeye",
"hoodedwidow",--boss
--待分类
"dustmoth","friendlyfruitfly","fruitfly","lordfruitfly","waterplant",
"moonbytterfly","bird_mutant","mutated_hound","spider_water","grassgator",
"oceanvine","coeantree_pillar","oceantree_cocoon","ticoon","pumpkin_lantern",
"tomato","eyeplant","mushgnome","archive_centipede","archive_centipede_husk",
"molebat","tentacle_pillar","swilson","viperling","viperlingfriend",
"scorpion","sporecloud","pollenmites","fruitbat","mock_dragonfly","gestalt_guard",
"balloon","bernie_big","lightflier",
}

local ATTRIBUTES_SYSTEM = GetModConfigData("attributes_system")
local function CommonCreatureEnable_Client(inst)
    if not inst:HasTag("dotaattributes") then
        inst:AddTag("dotaattributes")
    end
end
local function CommonCreatureEnable_Server(inst)
    if not inst.components.dotaattributes then
        inst:AddComponent("dotaattributes")	    --普通生物
    end
    if not inst.components.debuffable then
        inst:AddComponent("debuffable")	 
    end
    if not inst.components.dotaethereal then
        inst:AddComponent("dotaethereal")
    end
    if not inst.components.dotastunned then
        inst:AddComponent("dotastunned")
    end
    -- if not inst.components.dotadominatetarget then
    --     inst:AddComponent("dotadominatetarget")
    -- end

    -- TODO: 该组件存在bug，加入后无法选中生物，是实体覆盖导致的吗？
    -- if not inst.components.dotastunbar then
    --     inst:AddComponent("dotastunbar")
    -- end
end
if ATTRIBUTES_SYSTEM == 1 then    -- 白名单制
    for k, v in pairs(creature) do
        AddPrefabPostInit(v, function(inst)
            if not inst.components.dotaattributes then
                CommonCreatureEnable_Client(inst)
                if GLOBAL.TheWorld.ismastersim then
                    CommonCreatureEnable_Server(inst)
                    return inst
                end
            end
        end)
    end
elseif ATTRIBUTES_SYSTEM == 2 then    -- 全体
    AddPrefabPostInitAny(function(inst) 	
        if inst ~= nil 
         and inst:HasTag("_health") 
		 and inst:HasTag("_combat") 
         and not inst:HasTag("structure")  
         and not inst:HasTag("wall") 
         and not inst:HasTag("groundtile") 
         and not inst:HasTag("molebait")  
         and not inst:HasTag("shadowminion") 
         and not inst:HasTag("shadow") 
         and not inst:HasTag("boat")
         and not inst:HasTag("object")  
         and not inst:HasTag("plant")  
         and not inst:HasTag("player")  -- 玩家在另一个文件定义
         then 
            if inst:HasTag("epic") then
                CommonCreatureEnable_Client(inst)
                if GLOBAL.TheWorld.ismastersim then
                    CommonCreatureEnable_Server(inst)
                    return inst
                end
            else
                CommonCreatureEnable_Client(inst)
                if GLOBAL.TheWorld.ismastersim then
                    CommonCreatureEnable_Server(inst)
                    return inst
                end
            end
        end
    end)
elseif ATTRIBUTES_SYSTEM == 3 then    -- 禁用系统
	AddPrefabPostInitAny(function(inst) 	
        if inst ~= nil 
         and inst:HasTag("_health") 
         and inst:HasTag("_combat") 
         and not inst:HasTag("structure")  
         and not inst:HasTag("wall") 
         and not inst:HasTag("groundtile") 
         and not inst:HasTag("molebait")  
         and not inst:HasTag("shadowminion") 
         and not inst:HasTag("shadow") 
         and not inst:HasTag("boat")  
         and not inst:HasTag("player")
         then 
			 if GLOBAL.TheWorld.ismastersim then
				if inst.components.dotaattributes then
					inst:RemoveComponent("dotaattributes")
				end
				return inst
			end
        end
    end)
end