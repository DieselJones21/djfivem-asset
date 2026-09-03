Nocturne = Nocturne or {}

local accessCache = {} -- [src] = { allowed = bool, reason = string, at = number }

local function inAllowlist(src)
    local allow = Config.Access.Allowlist or {}
    if #allow == 0 then return false end

    local ids = {}
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        ids[identifier] = true
    end

    for i = 1, #allow do
        if ids[allow[i]] then
            return true
        end
    end
    return false
end

local function hasAce(src)
    local perm = Config.Access.AcePermission
    if not perm or perm == '' then return false end
    return IsPlayerAceAllowed(src, perm) == true
end

function Nocturne.EvaluateAccess(src, cb)
    if not Config.Access.RequireMembership then
        local result = { allowed = true, reason = 'open', method = 'open' }
        accessCache[src] = result
        if cb then cb(result) end
        return
    end

    if hasAce(src) then
        local result = { allowed = true, reason = 'ace', method = 'ace' }
        accessCache[src] = result
        if cb then cb(result) end
        return
    end

    if inAllowlist(src) then
        local result = { allowed = true, reason = 'allowlist', method = 'allowlist' }
        accessCache[src] = result
        if cb then cb(result) end
        return
    end

    if not Config.Discord.Enabled then
        local result = { allowed = false, reason = 'no_method', method = nil }
        accessCache[src] = result
        if cb then cb(result) end
        return
    end

    Nocturne.RefreshRoles(src, function(cache)
        if cache and cache.err == 'no_discord' then
            local result = { allowed = false, reason = 'discord_missing', method = 'discord' }
            accessCache[src] = result
            if cb then cb(result) end
            return
        end

        local allowed = Nocturne.HasConfiguredRole(src)
        local result = {
            allowed = allowed,
            reason = allowed and 'discord_role' or (cache and cache.err or 'no_role'),
            method = 'discord',
            discordId = cache and cache.discordId or nil,
        }
        accessCache[src] = result
        if cb then cb(result) end
    end)
end

function Nocturne.HasAccess(src)
    local cached = accessCache[src]
    if cached then
        return cached.allowed == true, cached
    end
    return false, nil
end

function Nocturne.GetAccess(src)
    return accessCache[src]
end

function Nocturne.RequireAccess(src)
    local ok = Nocturne.HasAccess(src)
    if ok then return true end
    Nocturne.Notify(src, (Locales[Config.Locale] or Locales.en).no_access)
    return false
end

AddEventHandler('playerDropped', function()
    accessCache[source] = nil
end)

exports('hasAccess', function(src)
    return Nocturne.HasAccess(src)
end)
