Nocturne = Nocturne or {}

function Nocturne.L(key, ...)
    local pack = Locales[Config.Locale] or Locales.en
    local str = pack[key] or key
    if select('#', ...) > 0 then
        return str:format(...)
    end
    return str
end

function Nocturne.LoadAnim(dict, timeout)
    if not dict or dict == '' then return false end
    timeout = timeout or 5000
    RequestAnimDict(dict)
    local deadline = GetGameTimer() + timeout
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > deadline then
            return false
        end
        Wait(10)
    end
    return true
end

function Nocturne.NearbyPlayers(maxDist)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myVeh = GetVehiclePedIsIn(myPed, false)
    local list = {}

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player)
            if ped ~= 0 and DoesEntityExist(ped) then
                local dist = #(GetEntityCoords(ped) - myCoords)
                if dist <= (maxDist or 8.0) then
                    local serverId = GetPlayerServerId(player)
                    list[#list + 1] = {
                        id = serverId,
                        name = GetPlayerName(player) or ('#' .. serverId),
                        distance = math.floor(dist * 10) / 10,
                        vehicle = GetVehiclePedIsIn(ped, false) ~= 0,
                        sameVehicle = myVeh ~= 0 and GetVehiclePedIsIn(ped, false) == myVeh,
                    }
                end
            end
        end
    end

    table.sort(list, function(a, b) return a.distance < b.distance end)
    return list
end

function Nocturne.ShowHelp(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
