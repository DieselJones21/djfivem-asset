# Nocturne ERP

Paid, Discord-synced erotic roleplay menu for FiveM. 18+ only.

Drop this folder into `resources` as `dj_nocturne` and add:

```
ensure dj_nocturne
```

Open in-game with **F7** or `/erp`. Stop a scene with **X** or `/erpstop`. Rebind the key in GTA settings.

## What you get

- Custom NUI (Nocturne club UI) — not RageUI
- Discord role membership with periodic resync
- Tebex / paid Discord role gate plus ACE and identifier allowlist
- Solo and synced (duet) poses using vanilla GTA animations
- Partner request / accept flow
- Scene speed and attach-offset nudge so you can tune synced scenes
- Categories: Intimate, Standing, Seated, Lying, Oral, Vehicle, Tease, Rough

Vanilla GTA clips cover the core catalog. Add your own streamed `.ycd` packs in `Config.CustomPoses` without editing the escrowed logic.

## Paid Discord access

1. Create a Discord bot, enable **Server Members Intent**, invite it to your guild.
2. Create a paid role (Tebex Discord package, or manual).
3. Put the guild id, bot token, and role id in `config.lua`:

```lua
Config.Discord = {
    Enabled = true,
    GuildId = '1234567890',
    BotToken = 'MTAx...',
    MemberRoleIds = { 'ROLE_ID_FOR_PAYING_MEMBERS' },
    BypassRoleIds = { 'STAFF_ROLE_ID' },
}

Config.Store = {
    TebexUrl = 'https://your-store.tebex.io/package/nocturne',
    DiscordInvite = 'https://discord.gg/yourserver',
    PriceLabel = '$12.99',
    ProductName = 'Nocturne Membership',
}
```

Players must have Discord linked in FiveM (`discord:` identifier). After purchase they can press **Refresh Discord** in the menu or run `/erpsync`.

Optional ACE bypass:

```
add_ace group.vip nocturne.member allow
```

Set `Config.Access.RequireMembership = false` while you test poses.

## Custom streamed poses

```lua
Config.CustomPoses = {
    {
        id = 'custom_missionary',
        label = 'Missionary',
        category = 'lying',
        type = 'synced',
        place = 'world',
        requester = { dict = 'your@dict', anim = 'male_clip', flag = 1 },
        partner   = { dict = 'your@dict', anim = 'female_clip', flag = 1 },
        attach = { bone = 0, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
    },
}
```

While a synced scene is playing, use the on-screen N/W/E/S/↑/↓ pad, then **Copy offset** and paste into `attach`.

## Commands

| Command | What it does |
|---|---|
| `/erp` | Toggle menu |
| `/erpstop` | Stop the current scene |
| `/erpsync` | Pull Discord roles again |

## Exports

```lua
-- server
exports['dj_nocturne']:hasAccess(source)
exports['dj_nocturne']:refreshRoles(source, cb)
```

## Preview the UI

Open `html/index.html` in a browser.

- `html/index.html` — member view
- `html/index.html?demo=locked` — paywall
- `html/index.html?request=1` — incoming scene request
