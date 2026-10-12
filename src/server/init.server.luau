-- Server entry point for +1 Frog Hop. Services are initialised in order
-- (init = set up state, no cross-service calls), then started.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Creating remotes must happen before any client asks for them.
require(ReplicatedStorage:WaitForChild("Shared").Net)

local Services = script.Services
local ORDER = {
	"WorldBuilder",
	"DataService",
	"MonetizationService",
	"HopService",
	"ShopService",
	"PetService",
	"ProgressionService",
	"DevService",
}

local loaded = {}
for _, name in ORDER do
	loaded[name] = require(Services:FindFirstChild(name))
end

for _, name in ORDER do
	local service = loaded[name]
	if service.init then
		service.init()
	end
end

for _, name in ORDER do
	local service = loaded[name]
	if service.start then
		task.spawn(service.start)
	end
end

print("[FrogHop] Server started")
