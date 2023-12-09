------------------------------------------------ 神符 - 生成 ----------------------------------------------

AddComponentPostInit("retrofitforestmap_anr", function(self)    -- 先测试下主世界的神符生成

assert(TheWorld.ismastersim, "RetrofitForestMapA_NR should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_PLACEMENT_ATTEMPTS = 50

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

local STRUCTURE_TAGS = {"structure"}
self.retrofit_dotarunes_content = true

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function RetrofitNewContentPrefab(inst, prefab, min_space, dist_from_structures, canplacefn, candidtate_nodes, on_add_prefab)
	local attempt = 1
	local topology = TheWorld.topology

	while attempt <= MAX_PLACEMENT_ATTEMPTS do
		local area = nil
		if candidtate_nodes ~= nil then
			area = candidtate_nodes[math.random(#candidtate_nodes)]
		else
			area = topology.nodes[math.random(#topology.nodes)]
		end

		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
		if #points_x == 1 and #points_y == 1 then
			local x = points_x[1]
			local z = points_y[1]

			if (canplacefn ~= nil and canplacefn(x, 0, z, prefab)) or
                (canplacefn == nil and TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, prefab)) then
				local ents = TheSim:FindEntities(x, 0, z, min_space)
				if #ents == 0 then
					if dist_from_structures ~= nil then
						ents = TheSim:FindEntities(x, 0, z, dist_from_structures, STRUCTURE_TAGS )
					end

					if #ents == 0 then
						local e = SpawnPrefab(prefab)
						e.Transform:SetPosition(x, 0, z)
						if on_add_prefab ~= nil then
							on_add_prefab(e)
						end
						break
					end
				end
			end
		end
		attempt = attempt + 1
	end
	print ("Retrofitting world for " .. prefab .. ": " .. (attempt <= MAX_PLACEMENT_ATTEMPTS and ("Success after "..attempt.." attempts.") or "Failed."))
	return attempt <= MAX_PLACEMENT_ATTEMPTS
end

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

local old_OnPostInit = self.OnPostInit
function self:OnPostInit()

    ---------------------------------------------------------------------------

    if self.retrofit_dotarunes_content then
		self.retrofit_dotarunes_content = nil

        -- 先检测下世界上是否有挂载神符生成的实体
		local requires_retrofitting_spawningground = true
	    for k,v in pairs(Ents) do
			if v ~= self.inst and v.prefab == "dota_runespawningground" then
				print("Retrofitting for DotaRune spawningground is not required.")
				requires_retrofitting_spawningground = false
				break
			end
		end

        -- 如果没有实体，就需要生成
		if requires_retrofitting_spawningground then
			local deciduousfn = function(x, y, z, prefab)
                return TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.DECIDUOUS    -- 生成在这什么东西的地形上（克劳斯地形，或许是岩石
            end

			print ("Retrofitting for A New Reign: Herd Mentality.")
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(self.inst, "dota_runespawningground", 1, 10, deciduousfn)
		end

	end

    ---------------------------------------------------------------------------

    old_OnPostInit(self)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

local old_OnSave = self.OnSave
function self:OnSave()
    local data = old_OnSave(self)
    if data then
        data.retrofit_dotarunes_content = self.retrofit_dotarunes_content or false
    end
    return data
end

local old_OnLoad = self.OnLoad
function self:OnLoad(data)
    old_OnLoad(self, data)
    if data ~= nil then
        self.retrofit_dotarunes_content = data.retrofit_dotarunes_content or true
    end
end

end)