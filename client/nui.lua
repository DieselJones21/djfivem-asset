Nocturne = Nocturne or {}

local nuiOpen = false
local accessState = {
    allowed = false,
    reason = 'pending',
    store = {},
    ui = {},
    categories = {},
    poses = {},
    adultConfirm = true,
}

function Nocturne.Toast(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
    SendNUIMessage({ action = 'toast', message = message })
end

function Nocturne.GetAccessState()
    return accessState
end

function Nocturne.IsOpen()
    return nuiOpen
end

function Nocturne.OpenMenu()
    if nuiOpen then return end
    nuiOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = 'open',
        access = accessState,
        nearby = Nocturne.NearbyPlayers(8.0),
        inScene = Nocturne.IsInScene(),
        scene = Nocturne.GetScene() and {
            active = Nocturne.IsInScene(),
            poseId = Nocturne.GetScene().poseId,
            speed = Nocturne.GetScene().speed,
            nudge = Nocturne.GetScene().nudge,
            role = Nocturne.GetScene().role,
        } or nil,
    })
end

function Nocturne.CloseMenu()
    if not nuiOpen then return end
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('nocturne:notify', function(message)
    Nocturne.Toast(message)
end)

RegisterNetEvent('nocturne:access', function(payload)
    accessState = payload or accessState
    SendNUIMessage({ action = 'access', access = accessState })
end)

RegisterNetEvent('nocturne:incomingRequest', function(payload)
    SendNUIMessage({ action = 'request', request = payload })
    Nocturne.Toast(Nocturne.L('request_incoming', payload.fromName, payload.poseLabel))
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end)

RegisterNUICallback('close', function(_, cb)
    Nocturne.CloseMenu()
    cb({ ok = true })
end)

RegisterNUICallback('play', function(data, cb)
    local poseId = data and data.poseId
    local targetId = data and data.targetId
    if not poseId then
        cb({ ok = false })
        return
    end
    TriggerServerEvent('nocturne:requestPose', targetId, poseId)
    cb({ ok = true })
end)

RegisterNUICallback('respond', function(data, cb)
    TriggerServerEvent('nocturne:respondRequest', data and data.accepted == true)
    cb({ ok = true })
end)

RegisterNUICallback('stop', function(_, cb)
    TriggerServerEvent('nocturne:stop')
    Nocturne.StopScene(false)
    cb({ ok = true })
end)

RegisterNUICallback('resync', function(_, cb)
    TriggerServerEvent('nocturne:resync')
    cb({ ok = true })
end)

RegisterNUICallback('nearby', function(_, cb)
    cb({ players = Nocturne.NearbyPlayers(8.0) })
end)

RegisterNUICallback('nudge', function(data, cb)
    local dx = tonumber(data and data.dx) or 0.0
    local dy = tonumber(data and data.dy) or 0.0
    local dz = tonumber(data and data.dz) or 0.0
    local drx = tonumber(data and data.drx) or 0.0
    local dry = tonumber(data and data.dry) or 0.0
    local drz = tonumber(data and data.drz) or 0.0
    TriggerServerEvent('nocturne:nudge', dx, dy, dz, drx, dry, drz)
    cb({ ok = true, nudge = Nocturne.GetScene().nudge })
end)

RegisterNUICallback('speed', function(data, cb)
    Nocturne.SetSpeed(tonumber(data and data.speed) or 1.0)
    cb({ ok = true, speed = Nocturne.GetScene().speed })
end)

RegisterNUICallback('copyOffset', function(_, cb)
    local s = Nocturne.GetScene()
    local a = s.attach or { x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0, bone = 0 }
    local n = s.nudge or { x = 0, y = 0, z = 0, rx = 0, ry = 0, rz = 0 }
    local text = ('{ bone = %s, x = %.3f, y = %.3f, z = %.3f, rx = %.3f, ry = %.3f, rz = %.3f }'):format(
        tostring(a.bone or 0),
        (a.x or 0) + n.x,
        (a.y or 0) + n.y,
        (a.z or 0) + n.z,
        (a.rx or 0) + n.rx,
        (a.ry or 0) + n.ry,
        (a.rz or 0) + n.rz
    )
    cb({ ok = true, text = text })
end)
