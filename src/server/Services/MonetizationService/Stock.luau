-- Limited-stock items ("STOCK 997/1000"). Sold counts live in a DataStore
-- shared by all servers; remaining stock is published as ReplicatedStorage
-- attributes ("Stock_<Product>") so clients can show it. Refreshed every
-- minute. The client stops offering an item at 0; a rare race can oversell
-- by a few, which is better than charging without granting.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Stock = {}

local store: DataStore? = nil

local function publish(name: string, sold: number)
	local limit = Monetization.Limited[name]
	ReplicatedStorage:SetAttribute("Stock_" .. name, math.max(limit - sold, 0))
end

-- Counts one sale of a limited item (no-op for unlimited items).
function Stock.claim(name: string)
	if not Monetization.Limited[name] then
		return
	end
	if not store then
		local current = ReplicatedStorage:GetAttribute("Stock_" .. name) or Monetization.Limited[name]
		ReplicatedStorage:SetAttribute("Stock_" .. name, math.max(current - 1, 0))
		return
	end
	task.spawn(function()
		local ok, sold = pcall(function()
			return (store :: DataStore):UpdateAsync(name, function(old)
				return (old or 0) + 1
			end)
		end)
		if ok then
			publish(name, sold)
		end
	end)
end

local function refresh()
	for name in Monetization.Limited do
		if store then
			local ok, sold = pcall(function()
				return (store :: DataStore):GetAsync(name)
			end)
			if ok then
				publish(name, sold or 0)
			end
		elseif ReplicatedStorage:GetAttribute("Stock_" .. name) == nil then
			publish(name, 0)
		end
	end
end

function Stock.start()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("FrogHop_LimitedStock_v1")
	end)
	store = if ok then result else nil
	refresh()
	task.spawn(function()
		while true do
			task.wait(60)
			refresh()
		end
	end)
end

return Stock
