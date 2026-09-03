Nocturne = Nocturne or {}

local function dbg(...)
    if Config.Debug then
        print('[nocturne]', ...)
    end
end

function Nocturne.Notify(src, message)
    TriggerClientEvent('nocturne:notify', src, message)
end

function Nocturne.GetDiscordId(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, 8) == 'discord:' then
            return identifier:sub(9)
        end
    end
    return nil
end

function Nocturne.GetLicense(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end
    return nil
end

local roleCache = {} -- [src] = { roles = {}, fetchedAt = 0, discordId = '', ok = false, err = nil }

local function roleSetFrom(list)
    local set = {}
    if not list then return set end
    for i = 1, #list do
        set[tostring(list[i])] = true
    end
    return set
end

local function fetchMember(discordId, cb)
    if not Config.Discord.Enabled then
        cb(nil, 'discord_disabled')
        return
    end

    local guildId = Config.Discord.GuildId
    local token = Config.Discord.BotToken
    if not guildId or guildId == '' or guildId == 'YOUR_DISCORD_GUILD_ID' then
        cb(nil, 'guild_not_configured')
        return
    end
    if not token or token == '' or token == 'YOUR_DISCORD_BOT_TOKEN' then
        cb(nil, 'token_not_configured')
        return
    end

    local url = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(guildId, discordId)
    PerformHttpRequest(url, function(status, body)
        if status == 200 and body and body ~= '' then
            local ok, data = pcall(json.decode, body)
            if ok and data then
                cb(data, nil)
                return
            end
            cb(nil, 'bad_json')
            return
        end
        if status == 404 then
            cb(nil, 'not_in_guild')
            return
        end
        dbg('discord http', status, body)
        cb(nil, 'http_' .. tostring(status))
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. token,
        ['Content-Type'] = 'application/json',
    })
end

function Nocturne.RefreshRoles(src, cb)
    local discordId = Nocturne.GetDiscordId(src)
    if not discordId then
        roleCache[src] = { roles = {}, fetchedAt = GetGameTimer(), discordId = nil, ok = false, err = 'no_discord' }
        if cb then cb(roleCache[src]) end
        return
    end

    fetchMember(discordId, function(member, err)
        if err or not member then
            roleCache[src] = {
                roles = {},
                fetchedAt = GetGameTimer(),
                discordId = discordId,
                ok = false,
                err = err or 'unknown',
            }
            if cb then cb(roleCache[src]) end
            return
        end

        local roles = {}
        if member.roles then
            for i = 1, #member.roles do
                roles[#roles + 1] = tostring(member.roles[i])
            end
        end

        roleCache[src] = {
            roles = roles,
            fetchedAt = GetGameTimer(),
            discordId = discordId,
            ok = true,
            err = nil,
            nick = member.nick,
            user = member.user and member.user.username or nil,
        }
        if cb then cb(roleCache[src]) end
    end)
end

function Nocturne.GetCachedRoles(src)
    return roleCache[src]
end

function Nocturne.HasConfiguredRole(src)
    local cached = roleCache[src]
    if not cached or not cached.ok then
        return false
    end

    local needed = roleSetFrom(Config.Discord.MemberRoleIds)
    local bypass = roleSetFrom(Config.Discord.BypassRoleIds)

    for i = 1, #cached.roles do
        local role = cached.roles[i]
        if needed[role] or bypass[role] then
            return true
        end
    end
    return false
end

function Nocturne.ClearPlayer(src)
    roleCache[src] = nil
end

AddEventHandler('playerDropped', function()
    Nocturne.ClearPlayer(source)
end)

exports('refreshRoles', function(src, cb)
    Nocturne.RefreshRoles(src, cb)
end)
