Nocturne = Nocturne or {}

local scene = {
    active = false,
    poseId = nil,
    role = nil,
    dict = nil,
    anim = nil,
    flag = 1,
    speed = 1.0,
    place = 'world',
    attach = nil,
    attachTo = nil,
    partner = nil,
    freeze = false,
    invincible = false,
    hideHud = false,
    nudge = { x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
}

local function hudThisFrame()
    HideHudAndRadarThisFrame()
    HideHelpTextThisFrame()
end

local function applyAttach()
    if not scene.active or not scene.attach or not scene.attachTo then return end
    local myPed = PlayerPedId()
    local targetPlayer = GetPlayerFromServerId(scene.attachTo)
    if targetPlayer == -1 then return end
    local host = GetPlayerPed(targetPlayer)
    if host == 0 or not DoesEntityExist(host) then return end

    local a = scene.attach
    local n = scene.nudge
    AttachEntityToEntity(
        myPed,
        host,
        a.bone or 0,
        (a.x or 0.0) + n.x,
        (a.y or 0.0) + n.y,
        (a.z or 0.0) + n.z,
        (a.rx or 0.0) + n.rx,
        (a.ry or 0.0) + n.ry,
        (a.rz or 0.0) + n.rz,
        false, false, false, false, 2, true
    )
end

function Nocturne.GetScene()
    return scene
end

function Nocturne.IsInScene()
    return scene.active
end

function Nocturne.PlayScene(data)
    Nocturne.StopScene(true)

    local ped = PlayerPedId()
    if not Nocturne.LoadAnim(data.dict) then
        Nocturne.Toast('Animation failed to load.')
        return
    end

    if data.place == 'vehicle' then
        if GetVehiclePedIsIn(ped, false) == 0 then
            Nocturne.Toast(Nocturne.L('vehicle_required'))
            return
        end
    elseif data.place ~= 'vehicle' then
        if GetVehiclePedIsIn(ped, false) ~= 0 then
            TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
            Wait(400)
        end
    end

    scene.active = true
    scene.poseId = data.poseId
    scene.role = data.role
    scene.dict = data.dict
    scene.anim = data.anim
    scene.flag = data.flag or 1
    scene.speed = data.speed or 1.0
    scene.place = data.place or 'world'
    scene.attach = data.attach
    scene.attachTo = data.attachTo
    scene.partner = data.partner
    scene.freeze = data.freeze and true or false
    scene.invincible = data.invincible and true or false
    scene.hideHud = data.hideHud and true or false
    scene.nudge = { x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 }

    ClearPedTasksImmediately(ped)
    TaskPlayAnim(ped, scene.dict, scene.anim, 8.0, -8.0, -1, scene.flag, 0.0, false, false, false)
    SetEntityAnimSpeed(ped, scene.dict, scene.anim, scene.speed)

    if scene.freeze then
        FreezeEntityPosition(ped, true)
    end
    if scene.invincible then
        SetEntityInvincible(ped, true)
    end

    if scene.attach and scene.attachTo then
        SetEntityCollision(ped, false, false)
        Wait(50)
        applyAttach()
    end

    SendNUIMessage({ action = 'scene', active = true, poseId = scene.poseId, role = scene.role })
end

function Nocturne.StopScene(silent)
    local ped = PlayerPedId()
    local wasActive = scene.active

    if IsEntityAttached(ped) then
        DetachEntity(ped, true, false)
    end

    if scene.dict then
        StopAnimTask(ped, scene.dict, scene.anim, 1.0)
    end
    ClearPedTasks(ped)

    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    SetEntityCollision(ped, true, true)

    scene.active = false
    scene.poseId = nil
    scene.role = nil
    scene.dict = nil
    scene.anim = nil
    scene.attach = nil
    scene.attachTo = nil
    scene.partner = nil

    SendNUIMessage({ action = 'scene', active = false })
    if wasActive and not silent then
        Nocturne.Toast(Nocturne.L('stopped'))
    end
end

function Nocturne.Nudge(dx, dy, dz, drx, dry, drz)
    if not scene.active then return end
    scene.nudge.x = scene.nudge.x + (dx or 0.0)
    scene.nudge.y = scene.nudge.y + (dy or 0.0)
    scene.nudge.z = scene.nudge.z + (dz or 0.0)
    scene.nudge.rx = scene.nudge.rx + (drx or 0.0)
    scene.nudge.ry = scene.nudge.ry + (dry or 0.0)
    scene.nudge.rz = scene.nudge.rz + (drz or 0.0)
    applyAttach()
    SendNUIMessage({ action = 'nudge', nudge = scene.nudge })
end

function Nocturne.SetSpeed(speed)
    if not scene.active then return end
    scene.speed = math.max(0.4, math.min(2.0, speed))
    local ped = PlayerPedId()
    SetEntityAnimSpeed(ped, scene.dict, scene.anim, scene.speed)
    SendNUIMessage({ action = 'speed', speed = scene.speed })
end

CreateThread(function()
    while true do
        if scene.active then
            local ped = PlayerPedId()
            if scene.hideHud then
                hudThisFrame()
            end
            if scene.dict and scene.anim and not IsEntityPlayingAnim(ped, scene.dict, scene.anim, 3) then
                TaskPlayAnim(ped, scene.dict, scene.anim, 8.0, -8.0, -1, scene.flag, 0.0, false, false, false)
                SetEntityAnimSpeed(ped, scene.dict, scene.anim, scene.speed)
                applyAttach()
            end
            Wait(0)
        else
            Wait(400)
        end
    end
end)

RegisterNetEvent('nocturne:play', function(data)
    Nocturne.PlayScene(data)
end)

RegisterNetEvent('nocturne:stopScene', function()
    Nocturne.StopScene(false)
end)

RegisterNetEvent('nocturne:applyNudge', function(dx, dy, dz, drx, dry, drz)
    Nocturne.Nudge(dx, dy, dz, drx, dry, drz)
end)
