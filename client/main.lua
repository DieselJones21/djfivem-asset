CreateThread(function()
    Wait(800)
    TriggerServerEvent('nocturne:ready')
end)

RegisterCommand(Config.Command, function()
    if Nocturne.IsOpen() then
        Nocturne.CloseMenu()
    else
        Nocturne.OpenMenu()
    end
end, false)

RegisterCommand(Config.StopCommand, function()
    TriggerServerEvent('nocturne:stop')
    Nocturne.StopScene(false)
end, false)

RegisterCommand('nocturne_open', function()
    if Nocturne.IsOpen() then
        Nocturne.CloseMenu()
    else
        Nocturne.OpenMenu()
    end
end, false)

RegisterKeyMapping('nocturne_open', 'Open Nocturne ERP', 'keyboard', Config.OpenKey or 'F7')

CreateThread(function()
    while true do
        if Nocturne.IsOpen() then
            Wait(Config.NearbyRefreshMs or 800)
            SendNUIMessage({ action = 'nearby', players = Nocturne.NearbyPlayers(8.0) })
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        if Nocturne.IsInScene() and not Nocturne.IsOpen() then
            Nocturne.ShowHelp('~INPUT_VEH_DUCK~ Stop scene   ~INPUT_REPLAY_START_STOP_RECORDING~ Menu')
            if IsControlJustPressed(0, 73) then -- X
                TriggerServerEvent('nocturne:stop')
                Nocturne.StopScene(false)
            end
            Wait(0)
        else
            Wait(300)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    Nocturne.CloseMenu()
    Nocturne.StopScene(true)
end)

exports('openMenu', function()
    Nocturne.OpenMenu()
end)

exports('closeMenu', function()
    Nocturne.CloseMenu()
end)

exports('stopScene', function()
    TriggerServerEvent('nocturne:stop')
    Nocturne.StopScene(false)
end)
