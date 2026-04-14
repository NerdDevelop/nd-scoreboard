-- ==========================================
-- QB SCOREBOARD — SERVER
-- Developed by: Nerd Developer
-- Website: https://nerd-developer.com
-- ==========================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================
-- EVENT STATE (toggled by other scripts)
-- ==========================================

local EventState = {}

-- Initialize all events as inactive
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, event in ipairs(Config.Events) do
        EventState[event.id] = false
    end
end)

-- ==========================================
-- SET EVENT ACTIVE / INACTIVE
-- Call from other scripts:
--   exports['qb-scoreboard']:SetEvent('store_robbery', true)
--   TriggerEvent('qb-scoreboard:server:setEvent', 'store_robbery', true)
-- ==========================================

RegisterNetEvent('qb-scoreboard:server:setEvent', function(eventId, state)
    EventState[eventId] = state == true
end)

AddEventHandler('qb-scoreboard:server:setEvent', function(eventId, state)
    EventState[eventId] = state == true
end)

-- ==========================================
-- MAIN CALLBACK — returns everything
-- ==========================================

QBCore.Functions.CreateCallback('qb-scoreboard:server:getData', function(source, cb)
    local players = {}
    local policeCount = 0
    local emsCount    = 0

    for _, playerId in ipairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        local name   = GetPlayerName(playerId) or 'Unknown'
        local ping   = GetPlayerPing(playerId) or 0

        local identifiers = {}
        for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
            table.insert(identifiers, GetPlayerIdentifier(playerId, i))
        end

        local jobName = 'unemployed'
        if Player then
            jobName = Player.PlayerData.job and Player.PlayerData.job.name or 'unemployed'
        end

        table.insert(players, {
            id          = playerId,
            name        = name,
            ping        = ping,
            job         = jobName,
            identifiers = identifiers,
        })

        -- Count police
        for _, j in ipairs(Config.PoliceJobs) do
            if jobName == j then policeCount = policeCount + 1 break end
        end

        -- Count EMS
        for _, j in ipairs(Config.EmsJobs) do
            if jobName == j then emsCount = emsCount + 1 break end
        end
    end

    -- Build events list with current state
    local events = {}
    for _, event in ipairs(Config.Events) do
        local required = tonumber(event.requiredPolice) or 0
        local ready = policeCount >= required
        table.insert(events, {
            id     = event.id,
            label  = event.label,
            icon   = event.icon,
            active = EventState[event.id] or false,
            requiredPolice = required,
            ready = ready,
        })
    end

    cb({
        players      = players,
        policeCount  = policeCount,
        emsCount     = emsCount,
        events       = events,
    })
end)

-- ==========================================
-- EXPORTS (for other scripts)
-- ==========================================

exports('SetEvent', function(eventId, state)
    EventState[eventId] = state == true
end)

exports('GetEventState', function(eventId)
    return EventState[eventId] or false
end)
