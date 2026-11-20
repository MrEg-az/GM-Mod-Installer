-- WeaponUnlock 1.0 - character-exclusive weapons usable by all characters
-- Completely independent from LocalRadio. Only modifies config data.

local WEAPON_UNLOCK_IDS = {
    80003408, 80301157,             -- Garm
    80003492,                       -- Bansy
    80001856, 80001857, 80001886, 80001893, 80001910,  -- Taffy recolors
    80003409, 80006209, 80301158,   -- Taffy Spark Hammer + Ocean Hammer
    80003410, 80003411,             -- Richie
    80003418, 80003423, 80003424,   -- Seymour
    80003500,                       -- Ke Si
}

local previous = rawget(_G, '__weaponUnlock')
if previous and previous.done then return 'READY already installed' end

local config = rawget(_G, 'LTConfig')
local sic = config and config.SceneitemConfig
if not sic or type(sic.GetConfig) ~= 'function' then
    return 'WAIT SceneitemConfig not ready'
end

local function log(text)
    local f = rawget(_G, '__localRadioLog')
    if f then f(tostring(text)) end
end

local unlocked = 0
for _, wid in ipairs(WEAPON_UNLOCK_IDS) do
    local row = sic.GetConfig(wid)
    if row and tonumber(row.WeaponBelong or 0) > 0 then
        rawset(row, 'WeaponBelong', 0)
        unlocked = unlocked + 1
        log('WEAPON_UNLOCK ' .. wid .. ' belong=0 ok')
    elseif row then
        log('WEAPON_UNLOCK ' .. wid .. ' already generic')
    else
        log('WEAPON_UNLOCK ' .. wid .. ' not found in config')
    end
end

rawset(_G, '__weaponUnlock', { done = true, count = unlocked })
log('WEAPON_UNLOCK done: ' .. unlocked .. '/' .. #WEAPON_UNLOCK_IDS .. ' weapons unlocked')
return 'WEAPON_UNLOCK done: ' .. unlocked .. ' weapons'
