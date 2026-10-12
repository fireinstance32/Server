-- Pop-up windows. One open at a time; each menu lives in its own module and
-- rebuilds from State whenever data changes. Names are what HUD buttons and
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

local Menus = {}

type Spec = { title: string, icon: string, height: number?, build: (Frame) -> (any) -> () }

local MENUS: { [string]: Spec } = {
	Shop = { title = "Shop", icon = "shop", build = ShopMenu.build },
	Rebirth = { title = "Rebirth", icon = "rebirth", height = 0.5, build = RebirthMenu.build },
	Pets = { title = "My Pets", icon = "pets", build = function(body)
		return InventoryMenu.build(body, "Pets")
	end },
	Inventory = { title = "Inventory", icon = "inventory", build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Frogs = { title = "Frogs", icon = "frog", build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Trails = { title = "Trails", icon = "trails", build = TrailsMenu.build },
	Daily = { title = "Daily Rewards", icon = "daily", height = 0.66, build = DailyMenu.build },
	Gifts = { title = "Gifts", icon = "gifts", height = 0.56, build = GiftsMenu.build },
}

local current: { name: string, frame: Frame, refresh: (any) -> () }? = nil

function Menus.close()
	if current then
		current.frame:Destroy()
		current = nil
		Hud.setMenuOpen(false)
	end
end

function Menus.open(name: string)
	local wasOpen = current and current.name == name
	Menus.close()
	if wasOpen then
		return -- clicking the same button again closes the menu
	end
	local spec = MENUS[name]
	if not spec then
		return
	end
	local frame, body = Window.create(spec.title, spec.icon, Menus.close, spec.height)
	Hud.setMenuOpen(true)
	local refresh = spec.build(body)
	current = { name = name, frame = frame, refresh = refresh }
	if State.data then
		refresh(State.data)
	end
end

function Menus.init()
	State.observe(function(data)
		if current then
			current.refresh(data)
		end
	end)
end

return Menus
