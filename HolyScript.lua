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
util.require_natives(1651208000)

-- All parents are created here
local self_root = menu.my_root()
local util_root = menu.list(self_root, 'Utility', {}, '')
local info_root = menu.list(util_root, 'Gather Info', {}, '')
local chat_root = menu.list(util_root, 'Chat Commands', {}, '')
local retarded_root = menu.list(self_root, 'Retarded Features', {}, '')
local mystuff_root = menu.list(self_root, 'Find My Stuff', {}, '')

-- Stuff i use with the info overlay
local function HostName()
    return players.get_name(players.get_host())
end

-- This allows to round a value
local function round(num)
    return math.ceil(num)
end

local function HostPing()
    return round(NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(players.get_host()))
end
local showHost = false
menu.toggle(info_root, "Show Host + Ping", { "ShowHost" }, "Show the current host and their ping to you", function(on)
    showHost = on
    while showHost do
        util.yield()
        util.draw_debug_text("Host: " .. HostName() .. " | " .. HostPing() .. " ms")
    end
end)

local function ScriptHostName()
    return players.get_name(players.get_script_host())
end

local function ScriptHostPing()
    return round(NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(players.get_script_host()))
end
local showSH = false
menu.toggle(info_root, "Show Script Host + Ping", { "ShowScriptHost" }, "Show the current script host and their ping to you", function(on)
    showSH = on
    while showSH do
        util.yield()
        util.draw_debug_text("Script Host: " .. ScriptHostName() .. " | " .. ScriptHostPing() .. " ms")
    end
end)
local showPlayerLang = false
menu.toggle(info_root, "Show Joins With Language", { "ShowJoinLang" }, "Will show you who joined with their game language", function(on)
    showPlayerLang = on
end)

-- Chat command stuff
menu.toggle(chat_root, "TP vehicle to you", { "!tpme" }, "Allows them to tp their vehicle to you", function(on)
    enableLookAtChat = on
end)
chat.on_message(function(pid, unused, content, tc)
    if not enableLookAtChat then
        return
    end
    local lowerContent = content:lower()
    if lowerContent:find('!tpme') and not lowerContent:find('> ') then
        chat.send_message('> ' .. players.get_name(pid) .. ' issued !tpme', tc, true, true)
        menu.trigger_commands("summon" .. players.get_name(pid))
    end
end)

-- Utility here
menu.action(util_root, "Escape Interior", { "Escape" }, "TP's upwards to get outside interior", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, 300)
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
    f:write(players.get_name(pid) .. " ("..players.get_rockstar_id(pid)..") joined at " .. os.date("%d %b %Y at %X")..".\n")
    f:close()
end)

-- Straight up retarded things
menu.action(retarded_root, "See Boobs", { "SeeBoobs" }, "Go see some boobies", function()
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), 114.65, -1285.72, 27.35, false, false, false, false)
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
    local player_list = menu.list(menu.player_root(pid), "HolyScript")

    menu.action(player_list, "Get their language of their game", { "GameLang" }, "Will tell the language their game is in", function()
        local language = players.get_language(pid)
        if regionDetect[language] then
            util.toast("Their game is in ".. regionDetect[language].lang)
            return
        end
        util.toast("I have no fucking clue")
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
    util.yield(100)
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