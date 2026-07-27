local repo = "https://raw.githubusercontent.com/shipychkaft-ux/expa/main/"

local function get(path)
    local url = repo .. path
    local src = game:HttpGet(url, true)
    if not src or src == "" then
        error("Failed to fetch (empty): " .. url)
    end
    return src
end

local function run(src)
    local fn, err = loadstring(src)
    if not fn then
        error("loadstring error: " .. tostring(err) .. " | src starts with: " .. src:sub(1, 100))
    end
    return fn()
end

-- Init shared.Mana
shared.Mana = shared.Mana or {}
local M = shared.Mana
M.Connections = M.Connections or {}
M.Friends = M.Friends or {}
M.Functions = M.Functions or {}
M.RunLoops = M.RunLoops or {}
M.Tabs = M.Tabs or {}

-- 1. Load modules into shared.Mana
M.PlayersHandler = run(get("playersHandler.lua"))
M.ToolHandler = run(get("toolHandler.lua"))
M.EspLibrary = run(get("espLibrary.lua"))
M.HUDLibrary = run(get("HUDLibrary.lua"))

-- 2. Run GuiLibrary (creates GUI library)
M.GuiLibrary = run(get("GuiLibrary.lua"))

-- 3. Create window & tabs
M.GuiLibrary:CreateWindow({ Name = "Mana" })
M.GuiLibrary:CreateTab({ Name = "Combat" })
M.GuiLibrary:CreateTab({ Name = "Movement" })
M.GuiLibrary:CreateTab({ Name = "Render" })
M.GuiLibrary:CreateTab({ Name = "Utility" })
M.GuiLibrary:CreateTab({ Name = "World" })

M.Loaded = true

-- 4. Run Universal (adds toggles) - config loads in background automatically
run(get("Universal.lua"))
