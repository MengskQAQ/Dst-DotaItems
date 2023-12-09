------------------------------------------------ 神符 - 生成 ----------------------------------------------
local function OnRegisterDotaRuneSpawningPoint(inst, spawnpoint)
    -- Assume the component still exists.
    inst.components.dotarunespawner:TryToRegisterSpawningPoint(spawnpoint)
end

local DotaRuneSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "DotaRuneSpawner should not exist on the client")

    self.inst = inst
    self.power_level = 1
    --self.rune = nil
    self.spawnpoints = {}

    inst:ListenForEvent("ms_registerdota_runespawningground", OnRegisterDotaRuneSpawningPoint)
end)


function DotaRuneSpawner:UnregisterDotaRuneSpawningPoint(spawnpoint)
    table.removearrayvalue(self.spawnpoints, spawnpoint)
end

function DotaRuneSpawner:RegisterDotaRuneSpawningPoint(spawnpoint)
    -- NOTES(JBK): This should not be called directly it exists for mods to get access to it.
    table.insert(self.spawnpoints, spawnpoint)
    self.inst:ListenForEvent("onremove", function() self:UnregisterDotaRuneSpawningPoint(spawnpoint) end, spawnpoint)
end

function DotaRuneSpawner:TryToRegisterSpawningPoint(spawnpoint)
    if table.contains(self.spawnpoints, spawnpoint) then
        return false
    end

    self:RegisterDotaRuneSpawningPoint(spawnpoint)
    return true
end

local RUNES_SPAWNLIST = {
    -- "dota_rune_arcane",
    "dota_rune_bounty",
    "dota_rune_double",
    "dota_rune_haste",
    -- "dota_rune_illusion",
    -- "dota_rune_invisbility",
    "dota_rune_regeneration",
    -- "dota_rune_shield",
    "dota_rune_water",
    -- "dota_rune_wisdom",
}


local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable", "structure", "plant", "tree" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end

local STRUCTURES_TAGS = {"structure", "blocker"}
local CANT_SPAWN_NEAR_TAGS = {"antlion_sinkhole_blocker"}
local IS_CLEAR_AREA_RADIUS = TILE_SCALE * 2.5

local NO_PLAYER_RADIUS = 35

function DotaRuneSpawner:GetPowerLevel()
    return self.power_level
end

function DotaRuneSpawner:IsValidSpawningPoint(x, y, z)
    for dx = -1, 1 do
        for dz = -1, 1 do
            if not TheWorld.Map:IsAboveGroundAtPoint(x + dx * TILE_SCALE, 0, z + dz * TILE_SCALE, false) then
                return false
            end
        end
    end
    return true
end

function DotaRuneSpawner:SpawnDotaRuneArena(x, y, z)
	local runename = RUNES_SPAWNLIST[math.random(1, #RUNES_SPAWNLIST)]
    local rune = SpawnPrefab(runename)
	rune.Transform:SetPosition(x, y, z)
    return rune
end

function DotaRuneSpawner:FindBestSpawningPoint()
    local structuresatspawnpoints = {}
    local x, y, z
    local valid = false
    local spawnpointscount = #self.spawnpoints
    if spawnpointscount == 0 then
        return nil, nil, nil -- No point.
    end

    for i, v in ipairs(self.spawnpoints) do
        x, y, z = v.Transform:GetWorldPosition()
        if self:IsValidSpawningPoint(x, y, z) and not IsAnyPlayerInRange(x, y, z, NO_PLAYER_RADIUS) then
            if TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, CANT_SPAWN_NEAR_TAGS)[1] == nil then
                local structures = #TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, nil, nil, STRUCTURES_TAGS)
                if structures == 0 then
                    valid = true -- No structures nearby and roomy for tiles.
                    break
                end
                structuresatspawnpoints[v] = structures
            end
        end
    end

    if not valid then
        local best_count = 12345
        for spawner, structs in pairs(structuresatspawnpoints) do
            if structs < best_count then
                best_count = structs
                x, y, z = spawner.Transform:GetWorldPosition()
                valid = true -- Lowest amount of structures and roomy for tiles.
            end
        end
    end

    if not valid then
        local spawner = self.spawnpoints[math.random(spawnpointscount)]
        local pos = spawner:GetPosition()
        x, y, z = pos:Get()

        local function IsValidSpawningPoint_Bridge(pt)
            return self:IsValidSpawningPoint(pt.x, pt.y, pt.z)
        end
        
        for r = 5, 15, 5 do
            local offset = FindWalkableOffset(pos, math.random() * TWOPI, r, 8, false, false, IsValidSpawningPoint_Bridge)
            if offset ~= nil then
                x = x + offset.x
                z = z + offset.z
                valid = true -- Do not care for amount of structures but it is roomy for tiles.
                break
            end
        end
    end

    return x, y, z
end

function DotaRuneSpawner:TryToSpawnDotaRuneArena()
    self.spawnpoints = shuffleArray(self.spawnpoints) -- Randomize outside of trying to find a good spawning point.

    local x, y, z = self:FindBestSpawningPoint()

    if x ~= nil then
        x, y, z = TheWorld.Map:GetTileCenterPoint(x, y, z)
        return self:SpawnDotaRuneArena(x, y, z)
    end
    return nil
end

function DotaRuneSpawner:OnDayChange()
    if self.rune ~= nil then
        self.rune:Remove()  -- 新的一天到来时，旧的神符将会消失
    end

    local rune = self:TryToSpawnDotaRuneArena()
    if rune == nil then
        return
    end

    self:WatchRune(rune)
end

function DotaRuneSpawner:WatchRune(rune)
    self.rune = rune
    self.inst:ListenForEvent("onremove", function()
        self.rune = nil
    end, self.rune)
end

function DotaRuneSpawner:OnPostInit()
    if TUNING.DOTA.SPAWN_RUNE then
        self:WatchWorldState("cycles", self.OnDayChange)
    end
end

function DotaRuneSpawner:OnSave()
    local data = {}
    local refs = nil

    if self.rune ~= nil then
        local rune_GUID = self.rune.GUID
        data.rune_GUID = rune_GUID
        refs = {rune_GUID}
    end

    return data, refs
end

function DotaRuneSpawner:OnLoad(data)

end

function DotaRuneSpawner:LoadPostPass(ents, data)
    local rune_GUID = data.rune_GUID
    if rune_GUID ~= nil then
        local rune = ents[rune_GUID]
        if rune ~= nil and rune.entity ~= nil then
            self:WatchRune(rune.entity)
        end
    end
end

return DotaRuneSpawner