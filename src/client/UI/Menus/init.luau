-- Pop-up windows. One open at a time; each menu lives in its own module and
-- rebuilds from State whenever data changes. Names are what HUD buttons and
-- world prompts pass to Menus.open.

local State = require(script.Parent.Parent.State)
local Window = require(script.Window)
local ShopMenu = require(script.Shop)
local RebirthMenu = require(script.RebirthMenu)
local InventoryMenu = require(script.Inventory)
local ComingSoonMenu = require(script.ComingSoonMenu)

local Menus = {}

type Spec = { title: string, icon: string, build: (Frame) -> (any) -> () }

local MENUS: { [string]: Spec } = {
	Shop = { title = "Shop", icon = "🛒", build = ShopMenu.build },
	Rebirth = { title = "Rebirth", icon = "🔁", build = RebirthMenu.build },
	Pets = { title = "My Pets", icon = "🐾", build = function(body)
		return InventoryMenu.build(body, "Pets")
	end },
	Inventory = { title = "Inventory", icon = "🎒", build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Frogs = { title = "Frogs", icon = "🐸", build = function(body)
		return InventoryMenu.build(body, "Frogs")
	end },
	Trails = { title = "Trails", icon = "✨", build = function(body)
		return ComingSoonMenu.build(body, "Trails arrive in Phase 2.4")
	end },
	Gifts = { title = "Gifts", icon = "🎁", build = function(body)
		return ComingSoonMenu.build(body, "Playtime gifts arrive in Phase 3.6")
	end },
}

local current: { name: string, frame: Frame, refresh: (any) -> () }? = nil

function Menus.close()
	if current then
		current.frame:Destroy()
		current = nil
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
	local frame, body = Window.create(spec.title, spec.icon, Menus.close)
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
