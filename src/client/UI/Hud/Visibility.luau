-- Shows or hides a HUD element without fighting the menu: while a window
-- has it hidden (Hud.setMenuOpen), the new state is remembered and applied
-- when the window closes.

local Visibility = {}

function Visibility.set(item: GuiObject, visible: boolean)
	if item:GetAttribute("MenuHidden") ~= nil then
		item:SetAttribute("MenuHidden", visible)
	else
		item.Visible = visible
	end
end

return Visibility
