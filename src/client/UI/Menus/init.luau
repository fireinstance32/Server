-- Pop-up windows. One open at a time; each menu lives in its own module and
-- refreshes from State whenever data changes (menus skip rebuilding cards
-- whose data is unchanged, see Util/Signature). Names are what HUD buttons and
-- world prompts pass to Menus.open.

local State = require(script.Parent.Parent.State)
local Hud = require(script.Parent.Hud)
local Window = require(script.Window)
local ShopMenu = require(script.Shop)
local RebirthMenu = require(script.RebirthMenu)
local InventoryMenu = require(script.Inventory)
local TrailsMenu = require(script.TrailsMenu)
local DailyMenu = require(script.DailyMenu)
local GiftsMenu = require(script.GiftsMenu)
local SettingsMenu = require(script.SettingsMenu)
local WorldsMenu = require(script.WorldsMenu)

local Menus = {}

type Spec = { title: string, icon: string, height: number?, tabs: boolean?, build: (Frame) -> (any) -> () }

local MENUS: { [string]: Spec } = {
	Shop = { title = "Shop", icon = "shop", build = ShopMenu.build },
	Rebirth = { title = "Rebirth", icon = "rebirth", height = 0.45, build = RebirthMenu.build },
	Pets = { title = "My Pets", icon = "pets", tabs = true, build = function(body)
		return InventoryMenu.build(body, "Pets")
	end },
	Inventory = { title = "Inventory", icon = "inventory", tabs = true, build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Frogs = { title = "Frogs", icon = "frog", tabs = true, build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Titles = { title = "My Titles", icon = "title", tabs = true, build = function(body)
		return InventoryMenu.build(body, "Titles")
	end },
	Boosts = { title = "My Boosts", icon = "boost", tabs = true, build = function(body)
		return InventoryMenu.build(body, "Boosts")
	end },
	Trails = { title = "Trails", icon = "trails", build = TrailsMenu.build },
	Daily = { title = "Daily Rewards", icon = "daily", height = 0.66, build = DailyMenu.build },
	Gifts = { title = "Gifts", icon = "gifts", height = 0.6, build = GiftsMenu.build },
	Worlds = { title = "Worlds", icon = "globe", height = 0.7, build = WorldsMenu.build },
	Settings = { title = "Settings", icon = "settings", height = 0.6, build = SettingsMenu.build },
}

local current: { name: string, frame: Frame, refresh: (any) -> () }? = nil

function Menus.close()
	if current then
		Window.dismiss(current.frame)
		current = nil
		Hud.setMenuOpen(false)
	end
end

-- Whether `name` is open, or (with no name) whether any menu is.
function Menus.isOpen(name: string?): boolean
	return current ~= nil and (name == nil or current.name == name)
end

-- Opens `name` without toggling: does nothing if it's already open.
function Menus.show(name: string)
	if Menus.isOpen(name) then
		return
	end
	Menus.close()
	local spec = MENUS[name]
	if not spec then
		return
	end
	local frame, body = Window.create(spec.title, spec.icon, Menus.close, spec.height, spec.tabs)
	Hud.setMenuOpen(true)
	-- Track the window before building it, so its X still works if the build
	-- errors.
	local entry = { name = name, frame = frame, refresh = function(_data) end }
	current = entry
	local ok, result = pcall(spec.build, body)
	if not ok then
		warn(`Menu {name} failed to build: {result}`)
		return
	end
	entry.refresh = result
	if State.data then
		result(State.data)
	end
end

-- HUD buttons: clicking the open menu's button again closes it.
function Menus.open(name: string)
	if Menus.isOpen(name) then
		Menus.close()
		return
	end
	Menus.show(name)
end

function Menus.init()
	State.observe(function(data)
		if current then
			current.refresh(data)
		end
	end)
end

return Menus
