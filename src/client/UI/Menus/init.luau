-- Pop-up windows. One open at a time; each menu lives in its own module and
-- rebuilds from State whenever data changes.

local Theme = require(script.Parent.Theme)
local State = require(script.Parent.Parent.State)
local Window = require(script.Window)

local C = Theme.Colors

local Menus = {}

local current: { name: string, frame: Frame, refresh: (any) -> () }? = nil

local MENUS = {
	Frogs = { title = "🐸 Frog Shop", color = C.Green, module = require(script.FrogsMenu) },
	Pets = { title = "🐾 Pets", color = C.Blue, module = require(script.PetsMenu) },
	Rebirth = { title = "🔁 Rebirth", color = C.Purple, module = require(script.RebirthMenu) },
	Codes = { title = "🎁 Codes", color = C.Gold, module = require(script.CodesMenu) },
}

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
		return -- clicking the same menu button again toggles it closed
	end
	local spec = MENUS[name]
	if not spec then
		return
	end
	local frame, body = Window.create(spec.title, spec.color, Menus.close)
	local refresh = spec.module.build(body)
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
