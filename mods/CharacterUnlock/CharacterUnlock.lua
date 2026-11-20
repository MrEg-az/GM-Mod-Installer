-- CharacterUnlock 1.0 - auto client part of the CharacterUnlock kit
-- Separate mod folder: Il2CppNativeKit/Mods/CharacterUnlock
-- Requires the server hotpatch (bin\patch\...\CharacterUnlock-install.json)
--
-- On entering the world it:
--   1. confirms the server patch via CharacterUnlock.Version
--   2. grants every missing FightSpiritConfig entry through the original
--      AddSpirit RPC (nothing is fabricated; already-owned are skipped)
--   3. makes owned-but-hidden characters visible/playable, clearing all
--      four UI blockers on the config proxy:
--        CanJoin=true, IsPublish=true, DispositionDontSwitch=false
--        + entry.Invisible=false
--
-- Toggle: set AUTO_GRANT=false below for display-only mode
-- (no RPCs, only visibility of already-owned characters).
-- Manual re-show after reconnect: run  CharacterUnlockShow()  in LuaRunner.

local AUTO_GRANT = true

local previous = rawget(_G, '__characterUnlock')
if previous and previous.version == 1 then return 'READY already installed' end

local function log(text)
    local f = rawget(_G, '__localRadioLog')
    if f then f('[CHARUNLOCK] ' .. tostring(text)) end
end

local manager = rawget(_G, 'gSpiritManager')
local config = rawget(_G, 'LTConfig') and LTConfig.FightSpiritConfig or nil
local gm = rawget(_G, 'gClientToGameGMDelegate')
local missing = {}
if not manager then missing[#missing + 1] = 'gSpiritManager' end
if manager and not manager.spiritViewDatas then missing[#missing + 1] = 'manager.spiritViewDatas' end
if not config then missing[#missing + 1] = 'LTConfig.FightSpiritConfig' end
if not gm then missing[#missing + 1] = 'gClientToGameGMDelegate' end
if gm and not gm.ClientToGameGmQA then missing[#missing + 1] = 'gm.ClientToGameGmQA' end
if gm and not gm.AddSpirit then missing[#missing + 1] = 'gm.AddSpirit' end
if #missing > 0 then
    log('WAIT missing: ' .. table.concat(missing, ', '))
    return 'WAIT spirit manager / GM delegate not ready (' .. table.concat(missing, ', ') .. ')'
end
log('READY: spirit manager + GM delegate present')

local function owned(id)
    local entry = manager:GetSpirit(id)
    return entry and not entry.__clientOnly
end

local function showOwned()
    local shown = 0
    for _, entry in pairs(manager.spiritViewDatas) do
        if not entry.__clientOnly and entry.config then
            -- all four hidden-character blockers:
            rawset(entry.config, 'CanJoin', true)            -- join/switch allowed
            rawset(entry.config, 'IsPublish', true)          -- published in the menu
            rawset(entry.config, 'DispositionDontSwitch', false) -- disposition gate off
            entry.Invisible = false                          -- silhouette/hidden flag off
            shown = shown + 1
        end
    end
    return shown
end

_G.CharacterUnlockShow = function()
    local n = showOwned()
    log('showOwned: ' .. n .. ' entries')
    return n
end

local report = { status = 'starting', results = {}, requested = 0, alreadyOwned = 0 }
_G.CharacterUnlockReport = report

local queue = {}
for i = 0, config.count - 1 do
    local row = config.LoadAt(i)
    if owned(row.Id) then
        report.alreadyOwned = report.alreadyOwned + 1
    elseif (row.Id == config.DefaultMale or row.Id == config.DefaultFemale)
        and (owned(config.DefaultMale) or owned(config.DefaultFemale)) then
        -- alternate-gender main hero: same slot, skipped like GrantAll does
    else
        queue[#queue + 1] = row.Id
    end
end

local function nextGrant()
    local id = table.remove(queue, 1)
    if not id then
        report.status = 'done'
        report.realOwned = showOwned()
        log('done; visible entries=' .. tostring(report.realOwned))
        return
    end
    report.requested = report.requested + 1
    local ok, err = pcall(function()
        gm:AddSpirit(id, 0).Callback = function(code)
            report.results[id] = code
            showOwned()
            nextGrant()
        end
    end)
    if not ok then
        report.status = 'error'
        report.error = tostring(err)
        log('AddSpirit failed: ' .. tostring(err))
    end
end

if AUTO_GRANT then
    gm:ClientToGameGmQA('CharacterUnlock.Version', '').Callback = function(code, result)
        if code ~= LTConfig.MessageConfig.Ok or type(result) ~= 'string'
            or not result:find('"characterUnlock":1', 1, true) then
            report.status = 'server-patch-unavailable'
            log('server patch NOT confirmed (code=' .. tostring(code) .. ') - display only')
            _G.CharacterUnlockShow()
            return
        end
        log('server patch confirmed; granting ' .. #queue .. ' missing')
        nextGrant()
    end
else
    report.status = 'display-only'
    _G.CharacterUnlockShow()
end

rawset(_G, '__characterUnlock', { version = 1, report = report })
return 'READY CharacterUnlock: ' .. #queue .. ' to grant, AUTO_GRANT=' .. tostring(AUTO_GRANT)
