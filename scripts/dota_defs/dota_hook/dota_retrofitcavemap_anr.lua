------------------------------------------------ 神符 - 生成 - 洞穴 ----------------------------------------------

AddComponentPostInit("dota_retrofitcavemap_anr", function(self)  

assert(TheWorld.ismastersim, "RetrofitCaveMapA_NR should not exist on client")

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

local function RetrofitNewCaveContentPrefab(inst, prefab, min_space, dist_from_structures, nightmare, searchnodes_override, ignore_terrain)
	local attempt = 1
	local topology = TheWorld.topology

	local ret = nil

	nightmare = nightmare or false

    local searchnodes
    if searchnodes_override then
        searchnodes = searchnodes_override
    else
        searchnodes = {}
        for k = 1, #topology.nodes do
            if (nightmare == table.contains(topology.nodes[k].tags, "Nightmare"))
                and (not table.contains(topology.nodes[k].tags, "Atrium"))
                and (not table.contains(topology.nodes[k].tags, "lunacyarea"))
                and (not string.find(topology.ids[k], "RuinedGuarden")) then

                table.insert(searchnodes, k)
            end
        end
    end

	if #searchnodes == 0 then
		print ("Retrofitting world for " .. prefab .. " FAILED: Could not find any " .. (nightmare and "Ruins" or "Caves") .. " nodes to spawn in.")
		return
	end

	while attempt <= MAX_PLACEMENT_ATTEMPTS do
		local searchnode = searchnodes[math.random(#searchnodes)]
		local area =  topology.nodes[searchnode]

		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
		if #points_x == 1 and #points_y == 1 then
			local x = points_x[1]
			local z = points_y[1]

			if ignore_terrain or TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x + min_space, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z + min_space, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x - min_space, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z - min_space, prefab) then

				local ents = TheSim:FindEntities(x, 0, z, min_space)
				if #ents == 0 then
					if dist_from_structures ~= nil then
						ents = TheSim:FindEntities(x, 0, z, dist_from_structures, STRUCTURE_TAGS )
					end

					if #ents == 0 then
						ret = SpawnPrefab(prefab)
						ret.Transform:SetPosition(x, 0, z)
						break
					end
				end
			end
		end
		attempt = attempt + 1
	end
	print ("Retrofitting world for " .. prefab .. ": " .. (attempt < MAX_PLACEMENT_ATTEMPTS and ("Success after "..attempt.." attempts.") or ("Failed to find a valid tile in "..#searchnodes.." nodes.")))
	return attempt < MAX_PLACEMENT_ATTEMPTS, ret
end

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

local old_OnPostInit = self.OnPostInit
function self:OnPostInit()

    ---------------------------------------------------------------------------
    
    if self.retrofit_dotarunes_content then
        self.retrofit_dotarunes_content = false

        local requires_retrofitting_spawningground = true
        for k,v in pairs(Ents) do
            if v ~= self.inst and v.prefab == "dota_runespawningground" then
                print("Retrofitting for DotaRune spawningground is not required.")
                requires_retrofitting_spawningground = false
                break
            end
        end

        if requires_retrofitting_spawningground then
            print("Retrofitting for DotaRune spawningground.")
            local searchnodes_override = {}
            local topology = TheWorld.topology
            for k = 1, #topology.nodes do
                if string.find(topology.ids[k], "LightPlantField") then
                    table.insert(searchnodes_override, k)
                end
            end
            local success = false
            for i = 1, 5 do
                success = RetrofitNewCaveContentPrefab(self.inst, "dota_runespawningground", 1, 10, nil, searchnodes_override) or success
            end
            if not success then
                -- Expand search area greatly.
                for k = 1, #topology.nodes do
                    if string.find(topology.ids[k], "WormPlantField") or
                        string.find(topology.ids[k], "FernGully") or
                        string.find(topology.ids[k], "SlurtlePlains") or
                        string.find(topology.ids[k], "MudWithRabbit") then
                        table.insert(searchnodes_override, k)
                    end
                end
                for i = 1, 5 do
                    success = RetrofitNewCaveContentPrefab(self.inst, "dota_runespawningground", 1, 10, nil, searchnodes_override) or success
                end
                if not success then
                    -- Allow all tile types we need at least one to spawn somewhere it does not matter where at this point.
                    while not success do
                        print ("Retrofitting for DotaRune spawningground. - Trying really hard to find a spot for one spawningground.")
                        success = RetrofitNewCaveContentPrefab(self.inst, "dota_runespawningground", 4, 40, nil, searchnodes_override, true)
                    end
                end
            end
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