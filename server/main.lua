Nocturne = Nocturne or {}

local posesById = {}
local pending = {} -- [targetSrc] = { from, poseId, expires }
local busy = {}    -- [src] = partnerSrc or true

local function rebuildIndex()
    posesById = {}
    local function add(list)
        for i = 1, #(list or {}) do
            local pose = list[i]
            if pose and pose.id then
                posesById[pose.id] = pose
            end
        end
    end
    add(Config.Poses)
    add(Config.CustomPoses)
end

rebuildIndex()

function Nocturne.GetPose(poseId)
    return posesById[poseId]
end

function Nocturne.CatalogForClient()
    local categories = {}
    for i = 1, #Config.Categories do
        categories[i] = Config.Categories[i]
    end

    local poses = {}
    local function pack(list)
        for i = 1, #(list or {}) do
            local p = list[i]
            poses[#poses + 1] = {
                id = p.id,
                label = p.label,
                category = p.category,
                type = p.type,
                place = p.place,
            }
        end
    end
    pack(Config.Poses)
    pack(Config.CustomPoses)
    return categories, poses
end

local function isBusy(src)
    return busy[src] ~= nil
end

local function clearBusy(src)
    local partner = busy[src]
    busy[src] = nil
    if type(partner) == 'number' then
        busy[partner] = nil
    end
end

local function playerPed(src)
    return GetPlayerPed(src)
end

local function coordsOf(src)
    local ped = playerPed(src)
    if ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function withinRange(a, b, pose)
    local ca, cb = coordsOf(a), coordsOf(b)
    if not ca or not cb then return false end
    local maxDist = (pose.place == 'vehicle') and Config.VehicleDistance or Config.MaxDistance
    return #(ca - cb) <= maxDist
end

local function pushAccess(src)
    local categories, poses = Nocturne.CatalogForClient()
    local access = Nocturne.GetAccess(src) or { allowed = false, reason = 'pending' }
    TriggerClientEvent('nocturne:access', src, {
        allowed = access.allowed == true,
        reason = access.reason,
        method = access.method,
        store = Config.Store,
        ui = Config.UI,
        adultConfirm = Config.AdultConfirm,
        categories = categories,
        poses = poses,
        key = Config.OpenKey,
    })
end

local function syncPlayer(src, silent)
    Nocturne.EvaluateAccess(src, function(result)
        pushAccess(src)
        if silent then return end
        local L = Locales[Config.Locale] or Locales.en
        if result.allowed then
            Nocturne.Notify(src, L.access_granted)
        elseif result.reason == 'discord_missing' then
            Nocturne.Notify(src, L.discord_missing)
        end
    end)
end

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(2500, function()
        if GetPlayerPing(src) > 0 then
            syncPlayer(src, true)
        end
    end)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    rebuildIndex()
    SetTimeout(1500, function()
        for _, src in ipairs(GetPlayers()) do
            syncPlayer(tonumber(src), true)
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(Config.RoleRefreshMs or 300000)
        for _, id in ipairs(GetPlayers()) do
            local src = tonumber(id)
            Nocturne.EvaluateAccess(src, function()
                pushAccess(src)
            end)
        end
    end
end)

RegisterNetEvent('nocturne:ready', function()
    syncPlayer(source, true)
end)

RegisterNetEvent('nocturne:resync', function()
    local src = source
    Nocturne.Notify(src, (Locales[Config.Locale] or Locales.en).discord_syncing)
    syncPlayer(src, false)
end)

RegisterCommand(Config.SyncCommand, function(src)
    if src == 0 then return end
    Nocturne.Notify(src, (Locales[Config.Locale] or Locales.en).discord_syncing)
    syncPlayer(src, false)
end, false)

RegisterNetEvent('nocturne:requestPose', function(targetId, poseId)
    local src = source
    if not Nocturne.RequireAccess(src) then return end

    local pose = Nocturne.GetPose(poseId)
    local L = Locales[Config.Locale] or Locales.en
    if not pose then
        Nocturne.Notify(src, L.pose_unknown)
        return
    end

    if pose.type == 'solo' then
        if isBusy(src) then
            Nocturne.Notify(src, L.request_busy)
            return
        end
        busy[src] = true
        TriggerClientEvent('nocturne:play', src, {
            poseId = pose.id,
            role = 'requester',
            speed = pose.speed or 1.0,
            freeze = Config.FreezeInScene,
            invincible = Config.InvincibleInScene,
            hideHud = Config.HideHudInScene,
            dict = pose.requester.dict,
            anim = pose.requester.anim,
            flag = pose.requester.flag or 1,
            place = pose.place,
            attach = nil,
            partner = nil,
        })
        return
    end

    targetId = tonumber(targetId)
    if not targetId or targetId == src or GetPlayerPing(targetId) <= 0 then
        Nocturne.Notify(src, L.no_partner)
        return
    end

    if isBusy(src) or isBusy(targetId) then
        Nocturne.Notify(src, L.request_busy)
        return
    end

    if not withinRange(src, targetId, pose) then
        Nocturne.Notify(src, L.too_far)
        return
    end

    pending[targetId] = {
        from = src,
        poseId = pose.id,
        expires = os.time() + (Config.RequestTimeout or 20),
    }

    TriggerClientEvent('nocturne:incomingRequest', targetId, {
        from = src,
        fromName = GetPlayerName(src) or ('#' .. src),
        poseId = pose.id,
        poseLabel = pose.label,
        timeout = Config.RequestTimeout or 20,
    })
    Nocturne.Notify(src, L.request_sent)
end)

RegisterNetEvent('nocturne:respondRequest', function(accepted)
    local src = source
    local req = pending[src]
    pending[src] = nil
    local L = Locales[Config.Locale] or Locales.en

    if not req then
        Nocturne.Notify(src, L.request_expired)
        return
    end

    if os.time() > req.expires then
        Nocturne.Notify(req.from, L.request_expired)
        Nocturne.Notify(src, L.request_expired)
        return
    end

    if not accepted then
        Nocturne.Notify(req.from, L.request_denied)
        return
    end

    if not Nocturne.RequireAccess(req.from) then return end

    local pose = Nocturne.GetPose(req.poseId)
    if not pose then return end

    if isBusy(src) or isBusy(req.from) then
        Nocturne.Notify(src, L.request_busy)
        Nocturne.Notify(req.from, L.request_busy)
        return
    end

    if not withinRange(req.from, src, pose) then
        Nocturne.Notify(src, L.too_far)
        Nocturne.Notify(req.from, L.too_far)
        return
    end

    busy[req.from] = src
    busy[src] = req.from

    local payload = {
        poseId = pose.id,
        speed = pose.speed or 1.0,
        freeze = Config.FreezeInScene,
        invincible = Config.InvincibleInScene,
        hideHud = Config.HideHudInScene,
        place = pose.place,
        attach = pose.attach,
    }

    TriggerClientEvent('nocturne:play', req.from, {
        poseId = payload.poseId,
        role = 'requester',
        speed = payload.speed,
        freeze = payload.freeze,
        invincible = payload.invincible,
        hideHud = payload.hideHud,
        dict = pose.requester.dict,
        anim = pose.requester.anim,
        flag = pose.requester.flag or 1,
        place = payload.place,
        attach = pose.attach,
        attachTo = nil,
        partner = src,
    })

    TriggerClientEvent('nocturne:play', src, {
        poseId = payload.poseId,
        role = 'partner',
        speed = payload.speed,
        freeze = payload.freeze,
        invincible = payload.invincible,
        hideHud = payload.hideHud,
        dict = pose.partner.dict,
        anim = pose.partner.anim,
        flag = pose.partner.flag or 1,
        place = payload.place,
        attach = pose.attach,
        partner = req.from,
        attachTo = req.from,
    })

    Nocturne.Notify(req.from, L.request_accepted)
    Nocturne.Notify(src, L.request_accepted)
end)

RegisterNetEvent('nocturne:stop', function()
    local src = source
    local partner = busy[src]
    clearBusy(src)
    TriggerClientEvent('nocturne:stopScene', src)
    if type(partner) == 'number' then
        TriggerClientEvent('nocturne:stopScene', partner)
    end
end)

RegisterNetEvent('nocturne:nudge', function(dx, dy, dz, drx, dry, drz)
    local src = source
    local partner = busy[src]
    if type(partner) ~= 'number' then return end
    -- Only the attached partner (or host) can nudge; broadcast to attached client
    TriggerClientEvent('nocturne:applyNudge', partner, dx, dy, dz, drx, dry, drz)
    TriggerClientEvent('nocturne:applyNudge', src, dx, dy, dz, drx, dry, drz)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local partner = busy[src]
    pending[src] = nil
    clearBusy(src)
    if type(partner) == 'number' then
        TriggerClientEvent('nocturne:stopScene', partner)
        Nocturne.Notify(partner, (Locales[Config.Locale] or Locales.en).stopped)
    end
end)
