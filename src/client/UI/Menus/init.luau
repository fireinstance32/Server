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

-- window: size / position / corner icon measured from the reference
-- screenshots (Window.Options; defaults = the reference's common window).
type Spec = { title: string, icon: string, window: Window.Options?, build: (Frame) -> (any) -> () }

-- Rebirth and Shop reference windows: 910×614, near-square corners, 3 px edge,
-- 57 px title capitals, 168 px corner icon over the top-left corner.
local SQUARE: Window.Options = {
	width = 910,
	height = 614,
	corner = 3,
	edge = 3,
	titleSize = 81,
	titleY = -21,
	iconSize = 168,
	iconX = 60,
	iconY = 0,
}
local SHOP: Window.Options = table.clone(SQUARE)
SHOP.fullBody = true -- the reference shop list scrolls under the title

local MENUS: { [string]: Spec } = {
	Shop = { title = "Shop", icon = "shop", window = SHOP, build = ShopMenu.build },
	Rebirth = { title = "Rebirth", icon = "rebirth", window = SQUARE, build = RebirthMenu.build },
	Pets = { title = "My Pets", icon = "pets", window = { tabs = true }, build = function(body)
		return InventoryMenu.build(body, "Pets")
	end },
	Inventory = { title = "Inventory", icon = "inventory", window = { tabs = true }, build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Frogs = { title = "Frogs", icon = "frog", window = { tabs = true }, build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Titles = { title = "My Titles", icon = "title", window = { tabs = true }, build = function(body)
		return InventoryMenu.build(body, "Titles")
	end },
	Boosts = { title = "My Boosts", icon = "boost", window = { tabs = true }, build = function(body)
		return InventoryMenu.build(body, "Boosts")
	end },
	Trails = { title = "Trails", icon = "trails", build = TrailsMenu.build },
	Daily = { title = "Daily Rewards", icon = "daily", window = { width = 1026, height = 695, titleSize = 85, titleY = -20 }, build = DailyMenu.build },
	Gifts = { title = "Playtime Rewards", icon = "gifts", window = { width = 910, height = 676 }, build = GiftsMenu.build },
	Worlds = { title = "Worlds", icon = "", window = { width = 1025, height = 805, titleSize = 85, titleY = -20 }, build = WorldsMenu.build },
	Settings = { title = "Settings", icon = "settings", window = { height = 560 }, build = SettingsMenu.build },
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
	local frame, body = Window.create(spec.title, spec.icon, Menus.close, spec.window)
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
