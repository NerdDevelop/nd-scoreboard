-- ==========================================
-- QB SCOREBOARD — CLIENT
-- Developed by: Nerd Developer
-- Website: https://nerd-developer.com
-- ==========================================

local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false

-- ==========================================
-- SEND CONFIG TO NUI
-- ==========================================

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    SendConfig()
end)

function SendConfig()
    SendNUIMessage({
        type = 'init',
        data = {
            serverName  = Config.ServerName or GetConvar('sv_projectName', 'My Server'),
            maxPlayers  = Config.MaxPlayers or 64,
            position    = Config.Position or 'right',
            colors      = Config.Colors or {},
            lang        = Config.Language or 'en',
            direction   = Config.Direction or nil,
            rtl         = Config.Rtl or nil,
            ui          = Config.UI or {},
            nui         = Config.Nui or {},
        }
    })
end

-- ==========================================
-- KEY BINDING
-- ==========================================

if Config.HoldToShow then
    RegisterCommand('+scoreboard_open', function()
        OpenScoreboard()
    end, false)

    RegisterCommand('-scoreboard_open', function()
        CloseScoreboard()
    end, false)

    RegisterKeyMapping('+scoreboard_open', 'Hold to show Scoreboard', 'keyboard', Config.OpenKey or 'HOME')
else
    RegisterCommand('scoreboard_toggle', function()
        if isOpen then CloseScoreboard() else OpenScoreboard() end
    end, false)

    RegisterKeyMapping('scoreboard_toggle', 'Toggle Scoreboard', 'keyboard', Config.OpenKey or 'HOME')
end

-- ==========================================
-- OPEN SCOREBOARD
-- ==========================================

function OpenScoreboard()
    if isOpen then return end
    isOpen = true

    SendNUIMessage({ type = 'open', data = { players = {}, policeCount = 0, emsCount = 0, events = {} } })

    FetchAndUpdate()
end

-- ==========================================
-- CLOSE SCOREBOARD
-- ==========================================

function CloseScoreboard()
    if not isOpen then return end
    isOpen = false
    SendNUIMessage({ type = 'close', data = {} })
end

-- ==========================================
-- FETCH DATA FROM SERVER
-- ==========================================

function FetchAndUpdate()
    QBCore.Functions.TriggerCallback('qb-scoreboard:server:getData', function(data)
        if not isOpen then return end
        SendNUIMessage({ type = 'update', data = data })
    end)
end

-- ==========================================
-- LIVE UPDATE LOOP (only updates, no re-open)
-- ==========================================

CreateThread(function()
    while true do
        Wait(4000)
        if isOpen then
            FetchAndUpdate()
        end
    end
end)

-- ==========================================
-- NUI CALLBACKS
-- ==========================================

RegisterNUICallback('nuiReady', function(data, cb)
    SendConfig()
    cb({})
end)

-- ==========================================
-- EXPORTS
-- ==========================================

exports('OpenScoreboard',  OpenScoreboard)
exports('CloseScoreboard', CloseScoreboard)
exports('IsOpen',          function() return isOpen end)


-- ==========================================
-- 3D IDs ABOVE PLAYER HEADS
-- ==========================================

local function GetHeadIdCfg()
    local c = Config and Config.HeadId or {}
    local colors = c.Colors or {}

    local idle    = colors.Idle or { r = 255, g = 255, b = 255, a = 235 }
    local talking = colors.Talking or { r = 235, g = 60, b = 60, a = 255 }

    return {
        OffsetZ = c.OffsetZ or 0.38,
        Scale   = c.Scale or 1.12,
        MaxDistance = c.MaxDistance or 28.0,
        MinDistance = c.MinDistance or 1.0,
        RequireLOS  = (c.RequireLOS ~= false),
        NoLOSMaxDistance = c.NoLOSMaxDistance or 6.0,
        Idle    = idle,
        Talking = talking,
    }
end

-- ==========================================
-- HELPERS
-- ==========================================

local function Clamp(v, mn, mx)
    return v < mn and mn or (v > mx and mx or v)
end

-- 3D Text ID (no background) — clear + outlined
local function DrawTag3D(wPos, dist, serverId, col, scaleMul)
    local sc    = Clamp(2.6 / dist, 0.08, 0.82)
    local fovSc = Clamp((1.0 / GetGameplayCamFov()) * 50.0, 0.4, 1.4)
    sc = sc * fovSc

    local textScale = Clamp(sc * 0.55 * (scaleMul or 1.0), 0.12, 0.90)

    SetDrawOrigin(wPos.x, wPos.y, wPos.z, 0)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.0, textScale)
    SetTextCentre(1)

    -- Crisp readability (outline + shadow)
    SetTextColour(col.r, col.g, col.b, col.a or 255)
    SetTextOutline()
    SetTextDropshadow(2, 0, 0, 0, 180)
    SetTextDropShadow()

    SetTextEntry('STRING')
    AddTextComponentString(tostring(serverId))
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- ==========================================
-- MAIN THREAD — 3D IDs
-- ==========================================

CreateThread(function()
    while true do
        if isOpen then
            local myPed  = PlayerPedId()

            for _, playerId in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(playerId)
                if not DoesEntityExist(ped) or IsEntityDead(ped) then goto continue end

                local isSelf  = (ped == myPed)
                local serverId = GetPlayerServerId(playerId)

                -- موقع فوق الرأس
                local boneIdx = GetEntityBoneIndexByName(ped, 'IK_Head')
                local hPos    = GetWorldPositionOfEntityBone(ped, boneIdx)
                local cfg     = GetHeadIdCfg()
                local wPos    = vector3(hPos.x, hPos.y, hPos.z + (cfg.OffsetZ or 0.38))

                -- تحقق LOS (إلا أنت)
                if not isSelf and not HasEntityClearLosToEntity(myPed, ped, 17) then
                    goto continue
                end

                -- المسافة
                local cam  = GetGameplayCamCoords()
                local dist = #(wPos - cam)
                if dist > (cfg.MaxDistance or 28.0) or dist < (cfg.MinDistance or 1.0) then goto continue end

                -- on-screen check (keeps it cheap)
                local onScreen = World3dToScreen2d(wPos.x, wPos.y, wPos.z)
                if not onScreen then goto continue end

                -- اختر اللون
                local talking = false
                local ok, res = pcall(MumbleIsPlayerTalking, playerId)
                if ok then talking = res end
                local col = talking and cfg.Talking or cfg.Idle

                -- LOS logic:
                -- - if RequireLOS=true: must have LOS, unless very close (NoLOSMaxDistance)
                if not isSelf then
                    local hasLos = HasEntityClearLosToEntity(myPed, ped, 17)
                    if cfg.RequireLOS then
                        if (not hasLos) and dist > (cfg.NoLOSMaxDistance or 6.0) then
                            goto continue
                        end
                    end
                end

                DrawTag3D(wPos, dist, serverId, col, cfg.Scale)

                ::continue::
            end

            Wait(0)
        else
            Wait(300)
        end
    end
end)
