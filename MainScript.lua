local repo = "https://raw.githubusercontent.com/shipychkaft-ux/expa/main/"

shared.Mana = shared.Mana or {}
local M = shared.Mana
M.Connections = M.Connections or {}
M.Friends = M.Friends or {}
M.Functions = M.Functions or {}
M.RunLoops = M.RunLoops or {}
M.Tabs = M.Tabs or {}

M.PlayersHandler = loadstring(game:HttpGet(repo .. "playersHandler.lua", true))()
M.ToolHandler = loadstring(game:HttpGet(repo .. "toolHandler.lua", true))()
M.EspLibrary = loadstring(game:HttpGet(repo .. "espLibrary.lua", true))()
M.HUDLibrary = loadstring(game:HttpGet(repo .. "HUDLibrary.lua", true))()

M.GuiLibrary = loadstring(game:HttpGet(repo .. "GuiLibrary.lua", true))()
M.Loaded = true

repeat task.wait() until M.GuiLibrary.ConfigLoaded
loadstring(game:HttpGet(repo .. "Universal.lua", true))()

M.GuiLibrary:CreateNotification("Mana", "Loaded! Press RightShift to open.", 3, "Info", true)
