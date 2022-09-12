--[[
Made by Holy#9756
I made this lua for learning and understanding lua myself. Some features are more usefull then the other
Those who helped me out:
Sapphire#1053 (always responds to my shitty questions <3)
jerry123#4508 "this is 150 lines shorter" (Sigh)
SoulReaper#2005
Murten#1154
Ren#5219
]]

-- For fun
util.toast("Please uninstall JerryScript due to it containing a virus!")

-- require latest natives
util.require_natives(1660775568)

-- All parents are created here
local self_root = menu.my_root()
local util_root = menu.list(self_root, 'Utility', {}, '')
local info_root = menu.list(util_root, 'Gather Info', {}, '')
local chat_root = menu.list(util_root, 'Chat Related Features', {}, '')
local retarded_root = menu.list(self_root, 'Retarded Features', {}, '')
local mystuff_root = menu.list(self_root, 'Find My Stuff', {}, '')
-- local experimental_root = menu.list(self_root, 'Experimental Features', {}, '')

-- Stuff i use with the info overlay

local function GetHost()
    return util.is_session_started() and players.get_host() or players.user()
end

local function HostName()
    return players.get_name(GetHost())
end

-- This allows to round a value
local function round(num)
    return math.ceil(num)
end

local function HostPing()
    return round(NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(GetHost))
end
local showHost = false
menu.toggle(info_root, "Show Host + Ping", { "ShowHost" }, "Show the current host and their ping to you", function(on)
    showHost = on
    while showHost do
        util.yield()
        if players.is_marked_as_modder(players.get_host()) then
            util.draw_debug_text("Host: " .. HostName() .. " (M) | " .. HostPing() .. " ms")
        else
            util.draw_debug_text("Host: " .. HostName() .. " | " .. HostPing() .. " ms")
        end
    end
end)

local function GetScriptHost()
    return util.is_session_started() and players.get_script_host() or players.user()
end

local function ScriptHostName()
    return players.get_name(GetScriptHost())
end

local function ScriptHostPing()
    return round(NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(GetScriptHost()))
end
local showSH = false
menu.toggle(info_root, "Show Script Host + Ping", { "ShowScriptHost" }, "Show the current script host and their ping to you", function(on)
    showSH = on
    while showSH do
        util.yield()
        if players.is_marked_as_modder(players.get_script_host()) then
            util.draw_debug_text("Script Host: " .. ScriptHostName() .. " (M) | " .. ScriptHostPing() .. " ms")
        else
            util.draw_debug_text("Script Host: " .. ScriptHostName() .. " | " .. ScriptHostPing() .. " ms")
        end
    end
end)

local showPlayerLang = false
menu.toggle(info_root, "Show Joins With Language", { "ShowJoinLang" }, "Will show you who joined with their game language", function(on)
    showPlayerLang = on
end)

menu.action(info_root, "Who Modding?", { "WhoMod" }, "Quickly show the current modders in session", function()
    local modders = {}
    for _,i in ipairs(players.list(false, true, true)) do
        if players.is_marked_as_modder(i) then
            table.insert(modders, players.get_name(i))
        end
    end
    if #modders == 0 then
        util.toast("No modders are currently in session")
    else
        util.toast("Modders: " .. table.concat(modders, ", "))
    end
end)

-- Chat stuff
menu.toggle(chat_root, "TP To You", { "!tpme" }, "Allows them to tp to you", function(on)
    enableLookAtChat = on
end)
chat.on_message(function(pid, unused, content, tc)
    if enableLookAtChat and pid ~= players.user() then
        local lowerContent = content:lower()
        if lowerContent:find('!tpme') and not lowerContent:find('> ') then
            chat.send_message('> ' .. players.get_name(pid) .. ' issued !tpme', tc, true, true)
            menu.trigger_commands("summon" .. players.get_name(pid))
        end
    end
end)

menu.toggle(chat_root, "No Jerry", { "ByeJerry" }, "No more forbidden word", function(on)
    jerryForbidden = on
end)
chat.on_message(function(pid, unused, content, tc)
    if not jerryForbidden then
        return
    end
    local lowerContent = content:lower()
    if lowerContent:find('Jerry') and not lowerContent:find('> ') then
        chat.send_message('> ' .. players.get_name(pid) .. ' will be removed for saying the forbidden word', tc, true, true)
        menu.trigger_commands("kick" .. players.get_name(pid))
    end
end)

-- Utility here
menu.action(util_root, "Escape Interior", { "Escape" }, "TP's upwards to get outside interior", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    local accurate
    local counter = 0
    repeat
        accurate, pos.z = util.get_ground_z(pos.x, pos.y)
        counter = counter + 1
        util.yield_once()
    until accurate or counter >= 2000
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z, false, false, false, false)
end)

local AlwaysAllGuns = false
menu.toggle(util_root, "Always All Weapons", { "Alwaysallguns" }, "Gives all weapons in every new session", function(on)
    AlwaysAllGuns = on
    while AlwaysAllGuns do
        while util.is_session_transition_active() do
            menu.trigger_commands("allguns")
            util.yield(10)
        end
        util.yield(10)
    end
end)

-- Creating own log
menu.toggle(info_root, "Enable Join Logging", { "PlayerLog" }, "Logs all player joins into PlayersLog.txt", function(on)
    enableLog = on
end)
players.on_join(function(pid)
    if not enableLog then
        return
    end
    -- "C:\Users\<username>\AppData\Roaming\Stand\Lua Scripts\HolyScript" is store
    local store = filesystem.scripts_dir() .. "\\HolyScript"
    if not filesystem.exists(store .. "\\PlayersLog.txt") then
        -- create directories if they doesn't exist
        filesystem.mkdirs(store)
        -- create file
        local f = io.open(store .. "\\PlayersLog.txt", "w")
        f:close()
    end
    -- write to file
    local f = io.open(store .. "\\PlayersLog.txt", "a")
    function dec_to_ipv4(ip)
        return string.format(
            "%i.%i.%i.%i",
            ip >> 24 & 0xFF,
            ip >> 16 & 0xFF,
            ip >> 8  & 0xFF,
            ip 		 & 0xFF
        )
    end
    f:write(players.get_name(pid) .. " ("..players.get_rockstar_id(pid)..") joined on " .. os.date("%d %b %Y at %X") .. " with IP: " .. dec_to_ipv4(players.get_connect_ip(pid)) ..".\n")
    f:close()
end)

-- Straight up retarded things
menu.action(retarded_root, "See Boobs", { "SeeBoobs" }, "Go see some boobies", function()
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), 114.65, -1285.72, 27.35, false, false, false, false)
    util.yield(1000)
    PAD._SET_CONTROL_NORMAL(0, 51, 1.0)
end)

menu.toggle_loop(retarded_root, "Bounty Loop Session", { "BountyLoopSession" }, "Loop a bounty on every player in session", function(on)
    while true do
        menu.trigger_commands("bountyall 10000")
        util.yield(5000)
    end
end)

menu.toggle_loop(retarded_root, "Auto Hop Sessions", { "AutoHop" }, "Auto hop sessions every 10 sec", function(on)
    if not util.is_session_transition_active() then
        util.yield(10000)
        menu.trigger_commands("gop")
    end
end)

menu.action(retarded_root, "Yeet V2", { "YeetV2" }, "Close your game with the power of lua", function()
    ENTITY.APPLY_FORCE_TO_ENTITY(0, 0, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false)
end)

local regionDetect = {
    [0]  = {kick = false, lang = "English"},
    [1]  = {kick = false, lang = "French"},
    [2]  = {kick = false, lang = "German"},
    [3]  = {kick = false, lang = "Italian"},
    [4]  = {kick = false, lang = "Spanish"},
    [5]  = {kick = false, lang = "Brazilian"},
    [6]  = {kick = false, lang = "Polish"},
    [7]  = {kick = false, lang = "Russian"},
    [8]  = {kick = false, lang = "Korean"},
    [9]  = {kick = false, lang = "Chinese Traditional"},
    [10] = {kick = false, lang = "Japanese"},
    [11] = {kick = false, lang = "Mexican"},
    [12] = {kick = false, lang = "Chinese Simplified"},
}

    --Player features here
local function generateFeatures(pid)
    menu.divider(menu.player_root(pid), "HolyScript")
    local retarded_list = menu.list(menu.player_root(pid), "Retarded")
    local toxic_list = menu.list(menu.player_root(pid), "Toxic")


    menu.action(retarded_list, "Get their language of their game", { "GameLang" }, "Will tell the language their game is in", function()
        local language = players.get_language(pid)
        if regionDetect[language] then
            util.toast("Their game is in ".. regionDetect[language].lang)
            return
        end
        util.toast("I have no fucking clue")
    end)

    local bountyLoop = false
    menu.toggle(retarded_list, "Bounty Loop", { "BountyPlayer" }, "Loops a bounty on specific player", function(on)
        bountyLoop = on
        local bounty = menu.ref_by_rel_path(menu.player_root(pid), "Trolling>Place Bounty")
        menu.trigger_command(bounty, "10000")
        while bountyLoop do
            if memory.read_int(memory.read_long(entities.handle_to_pointer(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)) + 0x10C8) + 0x01D8) == 1 then
                menu.trigger_command(bounty, "10000")
            end
            util.yield_once()
        end
    end)

    --Thanks Sapphire for helping to make this toxicity
    local taze = false
    menu.toggle(toxic_list, "Taze Hell", {"TazeHell"}, "Give them hell by tazing them whilst healing at the same time.", function(toggle)
        taze = toggle
        local autoheal = menu.ref_by_rel_path(menu.player_root(pid), "Friendly>Auto Heal")
        menu.trigger_command(autoheal, "on")
        while taze do
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z + 0.5, coords.x, coords.y, coords.z, 0, true, util.joaat("WEAPON_STUNGUN_MP"), PLAYER.PLAYER_PED_ID(), false, true, 0)
            util.yield_once()
        end
        menu.trigger_command(autoheal, "off")
    end)

    local atomize = false
    menu.toggle(toxic_list, "Bouncy Castle Simulator", {"BouncySimulator"}, "Make their ped act like its a bouncy castle.", function(toggle)
        atomize = toggle
        local autoheal = menu.ref_by_rel_path(menu.player_root(pid), "Friendly>Auto Heal")
        menu.trigger_command(autoheal, "on")
        while atomize do
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z + 0.5, coords.x, coords.y, coords.z, 0, true, util.joaat("weapon_raypistol"), PLAYER.PLAYER_PED_ID(), false, true, 0)
            util.yield(1000)
        end
        menu.trigger_command(autoheal, "off")
    end)

    local nuke = false
    menu.toggle(toxic_list, "Bring Hiroshima", {"Hiroshima"}, "Nuke their ass like its Hiroshima.", function(toggle)
        nuke = toggle
        while nuke do
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 29, 1.0, true, false, 1.0, false)
            util.yield()
        end
    end)
end

players.on_join(function(pid)
    if not showPlayerLang then return end
    while util.is_session_transition_active() do util.yield(100) end
    local language = players.get_language(pid)
    if regionDetect[language] then
        util.toast(players.get_name(pid).." joined with game language set to ".. regionDetect[language].lang ..".")
    end
end)

players.on_join(generateFeatures)
players.on_join(function(pid)
    util.yield(25000)
    while util.is_session_transition_active() do util.yield(100) end
    while not NETWORK.NETWORK_IS_PLAYER_ACTIVE(pid) do util.yield(100) end
end)
players.dispatch_on_join()

-- A hyperlink to my socials or how the fuck u want to classify
menu.hyperlink(mystuff_root, "Contact Me", "https://discordapp.com/users/874520660041433088", "Holy#9756 on Discord")
menu.hyperlink(mystuff_root, "My Github", "https://github.com/HolyJoey/", "Opens my Github page")
menu.hyperlink(mystuff_root, "OnlyFans?", "", "SoonTM?")

-- Without the script be dead after loading it
util.keep_running()
