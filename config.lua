--[[
    Nocturne ERP — server config
    Rename this resource folder to dj_nocturne and add `ensure dj_nocturne` to server.cfg.

    Access is granted when a player has ANY of:
      - A matching Discord role in Config.Discord.GuildId
      - The ACE permission Config.Access.AcePermission
      - Their license/discord identifier in Config.Access.Allowlist

    Typical paid flow: Tebex package grants the Discord role → Nocturne syncs it in-game.
]]

Config = {}

Config.Locale = 'en'
Config.Debug = false

-- 18+ gate shown the first time a player opens the menu this session
Config.AdultConfirm = true

Config.Command = 'erp'
Config.StopCommand = 'erpstop'
Config.SyncCommand = 'erpsync'
Config.OpenKey = 'F7' -- RegisterKeyMapping; players can rebind in GTA settings

Config.RequestTimeout = 20 -- seconds for partner to accept
Config.MaxDistance = 3.2
Config.VehicleDistance = 6.0
Config.RoleRefreshMs = 5 * 60 * 1000
Config.NearbyRefreshMs = 800

Config.HideHudInScene = true
Config.FreezeInScene = true
Config.InvincibleInScene = true

--[[
    Discord bot must be in the guild with Server Members Intent enabled.
    Bot token stays on the server. Never put it in client files.
]]
Config.Discord = {
    Enabled = true,
    GuildId = 'YOUR_DISCORD_GUILD_ID',
    BotToken = 'YOUR_DISCORD_BOT_TOKEN',
    -- Any one of these roles unlocks the menu (paid member, VIP, etc.)
    MemberRoleIds = {
        'YOUR_PAID_ROLE_ID',
    },
    -- Optional extra roles that also count (staff, lifetime, etc.)
    BypassRoleIds = {
        -- 'YOUR_STAFF_ROLE_ID',
    },
}

Config.Access = {
    -- If false, everyone can open the menu (useful while you test poses)
    RequireMembership = true,
    AcePermission = 'nocturne.member',
    Allowlist = {
        -- 'license:xxxxxxxx',
        -- 'discord:xxxxxxxx',
    },
}

Config.Store = {
    TebexUrl = 'https://your-store.tebex.io/package/nocturne',
    DiscordInvite = 'https://discord.gg/yourserver',
    PriceLabel = '$12.99',
    ProductName = 'Nocturne Membership',
}

Config.UI = {
    Brand = 'Nocturne',
    Tagline = 'Private rooms. Paid members only.',
}

--[[
    Pose catalog
    type        = 'solo' | 'synced'
    place       = 'world' | 'vehicle' | 'seat'
    requester/partner = { dict, anim, flag }
    attach      = bone + offsets for the partner ped (synced world scenes)
    flag 1      = loop  |  flag 0 = once  |  49 = loop + upper body + movable

    Drop custom .ycd packs in a stream folder on another resource, then
    add dict/anim names here. Vanilla GTA dicts below work with no extra files.
]]
Config.Categories = {
    { id = 'intimate',  label = 'Intimate',  hint = 'Kiss, hold, close' },
    { id = 'standing',  label = 'Standing',  hint = 'Upright scenes' },
    { id = 'seated',    label = 'Seated',    hint = 'Chairs, laps, edges' },
    { id = 'lying',     label = 'Lying',     hint = 'Bed and floor' },
    { id = 'oral',      label = 'Oral',      hint = 'Kneeling and vehicle' },
    { id = 'vehicle',   label = 'Vehicle',   hint = 'Cars and trucks' },
    { id = 'tease',     label = 'Tease',     hint = 'Strip and dance' },
    { id = 'rough',     label = 'Rough',     hint = 'Against the wall' },
}

Config.Poses = {
    ---------------------------------------------------------------- Intimate
    {
        id = 'kiss',
        label = 'Kiss',
        category = 'intimate',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mp_ped_interaction', anim = 'kisses_guy_a', flag = 1 },
        partner   = { dict = 'mp_ped_interaction', anim = 'kisses_guy_b', flag = 1 },
        attach = { bone = 9816, x = 0.0, y = 0.28, z = 0.0, rx = 0.0, ry = 0.0, rz = 180.0 },
    },
    {
        id = 'kiss_close',
        label = 'Close Kiss',
        category = 'intimate',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mp_ped_interaction', anim = 'kisses_guy_a', flag = 1 },
        partner   = { dict = 'mp_ped_interaction', anim = 'kisses_guy_b', flag = 1 },
        attach = { bone = 9816, x = 0.05, y = 0.22, z = 0.02, rx = 0.0, ry = 0.0, rz = 180.0 },
    },
    {
        id = 'hug',
        label = 'Hug',
        category = 'intimate',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mp_ped_interaction', anim = 'hug_guy_a', flag = 1 },
        partner   = { dict = 'mp_ped_interaction', anim = 'hug_guy_b', flag = 1 },
        attach = { bone = 9816, x = 0.0, y = 0.38, z = 0.0, rx = 0.0, ry = 0.0, rz = 180.0 },
    },
    {
        id = 'blow_kiss',
        label = 'Blow Kiss',
        category = 'intimate',
        type = 'solo',
        place = 'world',
        requester = { dict = 'anim@mp_player_intcelebrationfemale@blow_kiss', anim = 'blow_kiss', flag = 0 },
    },
    {
        id = 'blow_kiss_m',
        label = 'Blow Kiss (Alt)',
        category = 'intimate',
        type = 'solo',
        place = 'world',
        requester = { dict = 'anim@mp_player_intcelebrationmale@blow_kiss', anim = 'blow_kiss', flag = 0 },
    },
    {
        id = 'slow_grind_stand',
        label = 'Close Grind',
        category = 'intimate',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p1', anim = 'ld_girl_a_song_a_p1_m', flag = 1 },
        partner   = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p1', anim = 'ld_girl_a_song_a_p1_f', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.45, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },

    ---------------------------------------------------------------- Standing
    {
        id = 'standing_sex',
        label = 'Standing',
        category = 'standing',
        type = 'synced',
        place = 'world',
        requester = { dict = 'rcmpaparazzo_2', anim = 'shag_loop_a', flag = 1 },
        partner   = { dict = 'rcmpaparazzo_2', anim = 'shag_loop_poppy', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.35, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
    {
        id = 'standing_sex_alt',
        label = 'Standing (Deep)',
        category = 'standing',
        type = 'synced',
        place = 'world',
        requester = { dict = 'misscarsteal2pimpsex', anim = 'shagloop_pimp', flag = 1 },
        partner   = { dict = 'misscarsteal2pimpsex', anim = 'shagloop_hooker', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.40, z = 0.0, rx = 0.0, ry = 0.0, rz = 180.0 },
    },
    {
        id = 'pimp_sex',
        label = 'Bent Over',
        category = 'standing',
        type = 'synced',
        place = 'world',
        requester = { dict = 'misscarsteal2pimpsex', anim = 'pimpsex_punter', flag = 1 },
        partner   = { dict = 'misscarsteal2pimpsex', anim = 'pimpsex_hooker', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.55, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
    {
        id = 'pimp_watch',
        label = 'Watch & Take',
        category = 'standing',
        type = 'synced',
        place = 'world',
        requester = { dict = 'misscarsteal2pimpsex', anim = 'pimpsex_pimp', flag = 1 },
        partner   = { dict = 'misscarsteal2pimpsex', anim = 'pimpsex_hooker', flag = 1 },
        attach = { bone = 0, x = 0.15, y = 0.70, z = 0.0, rx = 0.0, ry = 0.0, rz = 90.0 },
    },

    ---------------------------------------------------------------- Seated / lap
    {
        id = 'lap_dance',
        label = 'Lap Dance',
        category = 'seated',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p1', anim = 'ld_girl_a_song_a_p1_m', flag = 1 },
        partner   = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p1', anim = 'ld_girl_a_song_a_p1_f', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
    {
        id = 'lap_dance_p2',
        label = 'Lap Dance II',
        category = 'seated',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p2', anim = 'ld_girl_a_song_a_p2_m', flag = 1 },
        partner   = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p2', anim = 'ld_girl_a_song_a_p2_f', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
    {
        id = 'lap_dance_p3',
        label = 'Lap Dance III',
        category = 'seated',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p3', anim = 'ld_girl_a_song_a_p3_m', flag = 1 },
        partner   = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p3', anim = 'ld_girl_a_song_a_p3_f', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
    {
        id = 'sit_straddle',
        label = 'Straddle',
        category = 'seated',
        type = 'synced',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_song_a_p1', anim = 'ld_girl_a_song_a_p1_m', flag = 1 },
        partner   = { dict = 'mini@strip_club@lap_dance@ld_girl_a_approach', anim = 'ld_girl_a_approach_f', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.20, z = 0.15, rx = 0.0, ry = 0.0, rz = 180.0 },
    },

    ---------------------------------------------------------------- Lying
    {
        id = 'love_bear',
        label = 'On the Floor',
        category = 'lying',
        type = 'solo',
        place = 'world',
        requester = { dict = 'timetable@trevor@skull_loving_bear', anim = 'skull_loving_bear', flag = 1 },
    },
    {
        id = 'sleep_cuddle',
        label = 'Sleepy Cuddle',
        category = 'lying',
        type = 'solo',
        place = 'world',
        requester = { dict = 'timetable@tracy@sleep@', anim = 'idle_c', flag = 1 },
    },
    {
        id = 'sunbathe',
        label = 'Laid Out',
        category = 'lying',
        type = 'solo',
        place = 'world',
        requester = { dict = 'amb@world_human_sunbathe@female@back@idle_a', anim = 'idle_a', flag = 1 },
    },
    {
        id = 'sunbathe_front',
        label = 'Face Down',
        category = 'lying',
        type = 'solo',
        place = 'world',
        requester = { dict = 'amb@world_human_sunbathe@female@front@idle_a', anim = 'idle_a', flag = 1 },
    },
    {
        id = 'sunbathe_m',
        label = 'Laid Out (Alt)',
        category = 'lying',
        type = 'solo',
        place = 'world',
        requester = { dict = 'amb@world_human_sunbathe@male@back@idle_a', anim = 'idle_a', flag = 1 },
    },

    ---------------------------------------------------------------- Oral
    {
        id = 'car_bj_low',
        label = 'Low Car — Oral',
        category = 'oral',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'mini@prostitutes@sexlow_veh', anim = 'low_car_bj_loop_player', flag = 1 },
        partner   = { dict = 'mini@prostitutes@sexlow_veh', anim = 'low_car_bj_loop_female', flag = 1 },
    },
    {
        id = 'car_bj',
        label = 'Car — Oral',
        category = 'oral',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'mini@prostitutes@sexnorm_veh', anim = 'bj_loop_male', flag = 1 },
        partner   = { dict = 'mini@prostitutes@sexnorm_veh', anim = 'bj_loop_prostitute', flag = 1 },
    },

    ---------------------------------------------------------------- Vehicle
    {
        id = 'car_sex_low',
        label = 'Low Car — Sex',
        category = 'vehicle',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'mini@prostitutes@sexlow_veh', anim = 'low_car_sex_loop_player', flag = 1 },
        partner   = { dict = 'mini@prostitutes@sexlow_veh', anim = 'low_car_sex_loop_female', flag = 1 },
    },
    {
        id = 'car_sex',
        label = 'Car — Sex',
        category = 'vehicle',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'mini@prostitutes@sexnorm_veh', anim = 'sex_loop_male', flag = 1 },
        partner   = { dict = 'mini@prostitutes@sexnorm_veh', anim = 'sex_loop_prostitute', flag = 1 },
    },
    {
        id = 'front_seat',
        label = 'Front Seat',
        category = 'vehicle',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'oddjobs@assassinate@vice@sex', anim = 'frontseat_carsex_loop_a', flag = 1 },
        partner   = { dict = 'oddjobs@assassinate@vice@sex', anim = 'frontseat_carsex_loop_bot', flag = 1 },
    },
    {
        id = 'front_seat_base',
        label = 'Front Seat (Hold)',
        category = 'vehicle',
        type = 'synced',
        place = 'vehicle',
        requester = { dict = 'oddjobs@assassinate@vice@sex', anim = 'frontseat_carsex_base_a', flag = 1 },
        partner   = { dict = 'oddjobs@assassinate@vice@sex', anim = 'frontseat_carsex_base_bot', flag = 1 },
    },

    ---------------------------------------------------------------- Tease / dance
    {
        id = 'private_dance_1',
        label = 'Private Dance I',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@private_dance@part1', anim = 'priv_dance_p1', flag = 1 },
    },
    {
        id = 'private_dance_2',
        label = 'Private Dance II',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@private_dance@part2', anim = 'priv_dance_p2', flag = 1 },
    },
    {
        id = 'private_dance_3',
        label = 'Private Dance III',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@private_dance@part3', anim = 'priv_dance_p3', flag = 1 },
    },
    {
        id = 'pole_1',
        label = 'Pole Dance I',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@pole_dance@pole_dance1', anim = 'pd_dance_01', flag = 1 },
    },
    {
        id = 'pole_2',
        label = 'Pole Dance II',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@pole_dance@pole_dance2', anim = 'pd_dance_02', flag = 1 },
    },
    {
        id = 'pole_3',
        label = 'Pole Dance III',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@pole_dance@pole_dance3', anim = 'pd_dance_03', flag = 1 },
    },
    {
        id = 'strip_idle',
        label = 'Slow Idle',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@idles@stripper', anim = 'stripper_idle_02', flag = 1 },
    },
    {
        id = 'strip_idle_b',
        label = 'Hip Sway',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@idles@stripper', anim = 'stripper_idle_04', flag = 1 },
    },
    {
        id = 'hooker_idle',
        label = 'Street Tease',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@hookers_spvanilla', anim = 'idle_a', flag = 1 },
    },
    {
        id = 'hooker_wait',
        label = 'Come Here',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@hookers_spvanilla', anim = 'idle_b', flag = 1 },
    },
    {
        id = 'lap_enter',
        label = 'Approach Lap',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'mini@strip_club@lap_dance@ld_girl_a_approach', anim = 'ld_girl_a_approach_f', flag = 0 },
    },
    {
        id = 'trevor_lap',
        label = 'Club Idle',
        category = 'tease',
        type = 'solo',
        place = 'world',
        requester = { dict = 'switch@trevor@mocks_lapdance', anim = '001443_01_trvs_28_idle_stripper', flag = 1 },
    },

    ---------------------------------------------------------------- Rough / wall
    {
        id = 'wall_sex',
        label = 'Against the Wall',
        category = 'rough',
        type = 'synced',
        place = 'world',
        requester = { dict = 'misscarsteal2pimpsex', anim = 'shagloop_pimp', flag = 1 },
        partner   = { dict = 'misscarsteal2pimpsex', anim = 'shagloop_hooker', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.22, z = 0.05, rx = 0.0, ry = 0.0, rz = 180.0 },
    },
    {
        id = 'standing_fast',
        label = 'Standing (Fast)',
        category = 'rough',
        type = 'synced',
        place = 'world',
        speed = 1.35,
        requester = { dict = 'rcmpaparazzo_2', anim = 'shag_loop_a', flag = 1 },
        partner   = { dict = 'rcmpaparazzo_2', anim = 'shag_loop_poppy', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.32, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
}

-- Optional custom streamed poses. Copy the table shape above.
-- Example after you add a streamed dict named `nocturne@custom@standing`:
-- {
--     id = 'custom_missionary',
--     label = 'Missionary',
--     category = 'lying',
--     type = 'synced',
--     place = 'world',
--     requester = { dict = 'nocturne@custom@lying', anim = 'missionary_m', flag = 1 },
--     partner   = { dict = 'nocturne@custom@lying', anim = 'missionary_f', flag = 1 },
--     attach = { bone = 0, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
-- }
Config.CustomPoses = {}
