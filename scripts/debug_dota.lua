-- TheInput:GetWorldEntityUnderMouse()用于获取鼠标下方的物体实体

function DotaPrintTable(table , level, key)	-- 调用时不要输入key值，key值已被用于函数自我调用
	key = key or ""
	level = level or 1
	local indent = ""

	for i = 1, level do
		indent = indent.."  "
	end

	if key ~= "" then
		print(indent..key.." ".."=".." ".."{")
	else
		print(indent .. "{")
	end

	key = ""
	for k,v in pairs(table) do
		if type(v) == "table" then
			key = k
			DotaPrintTable(v, level + 1, key)
		else
			local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
			print(content)  
		end
	end
	print(indent .. "}")
end

local function resetcooldownsfn(inst)
	if inst.components.rechargeable and not inst.components.rechargeable:IsCharged()  then 
		inst.components.rechargeable:SetCharge(inst.components.rechargeable.total)
	end
end

function DotaResetCoolDown(inst)
	if inst.components.inventory then
		inst.components.inventory:ForEachItem(resetcooldownsfn)
	end
	for _, v in pairs(inst.components.inventory.equipslots) do	-- 遍历装备栏
		if v.components.container ~= nil and v.components.container.canbeopened then
			v.components.container:ForEachItem(resetcooldownsfn)
		end
	end
end

function DotaCharacterAddTest(inst, num)
	if inst.components.dotacharacter ~= nil then
		num = num or 0.1
		inst.components.dotacharacter:AddStrength(num)
		inst.components.dotacharacter:AddAgility(num)
		inst.components.dotacharacter:AddIntelligence(num)
		inst.components.dotacharacter:AddAttributes(num)
		inst.components.dotacharacter:AddExtraHealth(num)
		inst.components.dotacharacter:AddHealthRegen(num)
		inst.components.dotacharacter:AddManaRegen(num)
		inst.components.dotacharacter:AddMaxMana(num)
		inst.components.dotacharacter:AddExtraArmor(num)
		inst.components.dotacharacter:AddAttackSpeed(num)
		inst.components.dotacharacter:AddExtraDamage(num)
		inst.components.dotacharacter:AddDamageRange(num)
		inst.components.dotacharacter:AddManaRegenAMP(num)
		inst.components.dotacharacter:AddHealthRegenAMP(num)
		inst.components.dotacharacter:AddDecrHealthRegenAMP(num)
		inst.components.dotacharacter:AddOutHealAMP(num)
		inst.components.dotacharacter:AddHealedAMP(num)
		inst.components.dotacharacter:AddSpellDamageAMP(num)
		inst.components.dotacharacter:AddLifesteal(num)
		inst.components.dotacharacter:AddLifestealAMP(num)
		inst.components.dotacharacter:AddSpellLifesteal(num)
		inst.components.dotacharacter:AddSpellLifestealAMP(num)
		inst.components.dotacharacter:AddSpellResistance(num)
		inst.components.dotacharacter:AddStatusResistance(num)
		inst.components.dotacharacter:AddDodgeChance(num)
		inst.components.dotacharacter:AddMissChance(num)
		inst.components.dotacharacter:AddAccuracy(num)
		inst.components.dotacharacter:AddDecrLifeStealAMP(num)
		inst.components.dotacharacter:AddDecrSpellLifeStealAMP(num)
		inst.components.dotacharacter:AddDecrSpellDamageAMP(num)
		inst.components.dotacharacter:AddDecrHealedAMP(num)
		inst.components.dotacharacter:AddSpellWeak(num)
		inst.components.dotacharacter:AddCDReduction(num)
	end
end

function DotaCharacterRemoveTest(inst, num)
	if inst.components.dotacharacter ~= nil then
		num = num or 0.1
		inst.components.dotacharacter:RemoveStrength(num)
		inst.components.dotacharacter:RemoveAgility(num)
		inst.components.dotacharacter:RemoveIntelligence(num)
		inst.components.dotacharacter:RemoveAttributes(num)
		inst.components.dotacharacter:RemoveExtraHealth(num)
		inst.components.dotacharacter:RemoveHealthRegen(num)
		inst.components.dotacharacter:RemoveManaRegen(num)
		inst.components.dotacharacter:RemoveMaxMana(num)
		inst.components.dotacharacter:RemoveExtraArmor(num)
		inst.components.dotacharacter:RemoveAttackSpeed(num)
		inst.components.dotacharacter:RemoveExtraDamage(num)
		inst.components.dotacharacter:RemoveDamageRange(num)
		inst.components.dotacharacter:RemoveManaRegenAMP(num)
		inst.components.dotacharacter:RemoveHealthRegenAMP(num)
		inst.components.dotacharacter:RemoveDecrHealthRegenAMP(num)
		inst.components.dotacharacter:RemoveOutHealAMP(num)
		inst.components.dotacharacter:RemoveHealedAMP(num)
		inst.components.dotacharacter:RemoveSpellDamageAMP(num)
		inst.components.dotacharacter:RemoveLifesteal(num)
		inst.components.dotacharacter:RemoveLifestealAMP(num)
		inst.components.dotacharacter:RemoveSpellLifesteal(num)
		inst.components.dotacharacter:RemoveSpellLifestealAMP(num)
		inst.components.dotacharacter:RemoveSpellResistance(num)
		inst.components.dotacharacter:RemoveStatusResistance(num)
		inst.components.dotacharacter:RemoveDodgeChance(num)
		inst.components.dotacharacter:RemoveMissChance(num)
		inst.components.dotacharacter:RemoveAccuracy(num)
		inst.components.dotacharacter:RemoveDecrLifeStealAMP(num)
		inst.components.dotacharacter:RemoveDecrSpellLifeStealAMP(num)
		inst.components.dotacharacter:RemoveDecrSpellDamageAMP(num)
		inst.components.dotacharacter:RemoveDecrHealedAMP(num)
		inst.components.dotacharacter:RemoveSpellWeak(num)
		inst.components.dotacharacter:RemoveCDReduction(num)
	end
end

function DotaEmptyCharacterTest(inst)
	if inst.components.dotacharacter ~= nil then
		for k,v in pairs(inst.components.dotacharacter.equippable) do
			if k then k = {} end
		end
	end
end

local small = {
"spider","spider_warrior","spider_moon","spider_hider","spider_spitter",
"spider_dropper","tentacle_pillar_arm","spider_healer",
"robin","puffin","squid","gnarwail","chester","hutch","glommer",
"knight","bishop","rook","eyeturret","deer_red","deer_blue","ghost",
"penguin","mutated_penguin","stalker_minion1","mandrake_active","gingerbreadpig",
"killerbee","mossling","bat","slurtle","tentacle","stalker_minion2",
"smallbird","pigman","teenbird","dustmoth","stalker_minion","moonpig",
"moonbutterfly","robin_winter","crow","canary","buzzard","bunnyman","worm",
"friendlyfruitfly","fruitfly","lordfruitfly","merm","mermguard",
"snurtle","rocky","slurper","deer","bee","butterfly","mosquito","rabbit","wobster_moonglass_land",
"shark","waterplant","canary_poisoned","eyeplant",
"grassgekko","pigguard","carrat","birchnutdrake","mole","moonbytterfly",
"lavae_pet","lavae","clayhound",
---------
"bird_mutant",
------------
"stumpling","fruitbat","glacialhound","sporehound",
-------------------
"spider_water",
"grassgator","oceanvine",
"coeantree_pillar","oceantree_cocoon",
--------------------------

"ticoon",
"powder_monkey",
"prime_mate",

"woodpecker",
"mutated_hound",
}
local large = {
"pumpkin_lantern","tomato","bearger",

"beefalo","tallbird","koalefant_summer","koalefant_winter","lightninggoat","spat","perd","eyeplant",
"krampus","monkey","knight_nightmare","mushgnome","archive_centipede","archive_centipede_husk",
"mutatedhound","firehound","hound","icehound","frog","gingerbreadwarg","malbatross",
"molebat","mermking","beeguard","tentacle_pillar","claywarg","warg","spiderqueen",
"vampirebat","uncompromising_rat","swilson","magmahound","shockworm",
"viperworm","viperling","hoodedwidow","viperlingfriend","shadow_teleporter_light",
"spider_trapdoor","chimp","aphid","antlion_sinkhole_lava","blueberryplant",
"bushcrab","cave_banana_tree","mushtree_tall","hooded_mushtree_medium","hooded_mushtree_small",
"hooded_mushtree_tall","mushtree_medium","mushtree_small","snowmong","snapdragon","scorpion","sporecloud",
"pollenmites","fruitbat","mock_dragonfly","gestalt_guard",
"bishop_nightmare","rook_nightmare","catcoon","balloon","bernie_big","lightflier",
}

local count = 1
function DotaCreatureTest(inst)
	for k, v in pairs(small) do
		if k == count then
			local x, y, z = inst.Transform:GetWorldPosition()
			local item = SpawnPrefab(v).Transform:SetPosition(x, 0, z)
			if item ~= nil and item:HasTag("_health") and item:HasTag("_combat") 
			 and not item:HasTag("structure")  
			 and not item:HasTag("wall") 
			 and not item:HasTag("groundtile") 
			 and not item:HasTag("molebait")  
			 and not item:HasTag("shadowminion") 
			 and not item:HasTag("shadow") 
			 and not item:HasTag("boat")  
			 and not item:HasTag("player")
			then
				inst.components.talker:Say("Key：".. count .. " 名称： " .. v .. " 检查成功")
			elseif item ~= nil then
				inst.components.talker:Say("Key：".. count .. " 名称： " .. v .. " 检查成功")
			elseif item == nil then
				inst.components.talker:Say("Key：".. count .. " 名称： " .. v .. " 未检测到实体")
			end
		end
	end
	count = count + 1
end
function DotaCreatureTestPrintAll()
	local a = 1
	for k, v in pairs(large) do
		local item = SpawnPrefab(v)
		if item ~= nil and item:HasTag("_health") and item:HasTag("_combat") 
		 and not item:HasTag("structure")  
		 and not item:HasTag("wall") 
		 and not item:HasTag("groundtile") 
		 and not item:HasTag("molebait")  
		 and not item:HasTag("shadowminion") 
		 and not item:HasTag("shadow") 
		 and not item:HasTag("boat")  
		 and not item:HasTag("player")
		then
			print("Key：".. a .. " 名称： " .. v .. " 成功")
		elseif item ~= nil then
			print("Key：".. a .. " 名称： " .. v .. " 失败")
		elseif item == nil then
			print("Key：".. a .. " 名称： " .. v .. " 未检测到实体")
		end
		a = a + 1
	end
end
function DotaCreatureTestCount(inst, a)
	if a then count = a end
	for k, v in pairs(small) do
		if k == count then
			inst.components.talker:Say("已指定Key：".. count .. " 名称： " .. v)
		end
	end
end
function DotaCreatureTestOnly(inst, num)
	for k, v in pairs(small) do
		if k == num then
			inst.components.talker:Say("计数：".. count .. " 名称： " .. v)
			local x, y, z = inst.Transform:GetWorldPosition()
			SpawnPrefab(v).Transform:SetPosition(x, 0, z)
		end
	end
end
function DotaGoToState(inst, sg, data)
	if inst and inst.sg then
		inst.sg:GoToState(sg, data)
	end
end
function DotaPlayAnimation(inst, anim)
	if inst and inst.Animation then
		inst.Animation:PlayAnimation(anim)
	end
end
function DotaPushAnimation(inst, anim, bool)
	if inst and inst.Animation then
		inst.Animation:PushAnimation(anim, bool)
	end
end

function DotaGetDebugString(inst)
	if inst and inst.entity then
		inst.entity:GetDebugString()
		print("   ")
		print(inst.entity:GetDebugString())
	else
		print("未获取到实体")
	end
end


function DotaEmptyPrint()
	print = function(...) end
end
local old_print = print
function DotaResetPrint()
	print = old_print
end
function DotaNewPrint()
	print = function(str)
		for i in string.gmatch(str, "%S+") do
			old_print(i)
		end
	end
end
function DotaAddTag(inst)
	local aa=1
	for i=1, 100 do
		aa = aa + 1
		for k1, v1 in pairs(small) do
			ThePlayer:AddTag(v1..aa)
		end
	end
end

function DotaFindTag(inst)
	local pos = inst:GetPosition()
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30, { "_combat" }, { "player" })
	for _, ent in ipairs(ents) do
		print(ent.entity:GetDebugString())
		print()
		print(ent:GetDebugString())
		print()
	end
end

function DotaFindCloestEntity(creature)
	local inst = creature or ThePlayer
	local pos = inst:GetPosition()
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 10, { "_combat" }, { "player" })
	for _, ent in ipairs(ents) do
		print(ent.prefab)
		return ent
	end
end

function DotaGetEntity(ThePlayer)
	return ThePlayer and ThePlayer.components.inventory:GetActiveItem()
end

