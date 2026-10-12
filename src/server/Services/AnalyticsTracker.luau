-- Roblox Analytics: the onboarding funnel (Config/Funnel), logged as player
-- data changes, and Wins spending (economy sinks). All calls are pcall'd so
-- analytics can never break gameplay.

local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Funnel = require(ReplicatedStorage:WaitForChild("Shared").Config.Funnel)

local DataService = require(script.Parent.DataService)

local AnalyticsTracker = {}

local function logFunnel(player: Player, data: any)
	for _, step in Funnel.newSteps(data, data.funnelStep) do
		local ok = pcall(function()
			AnalyticsService:LogOnboardingFunnelStepEvent(player, step, Funnel.Steps[step].name)
		end)
		if not ok then
			return
		end
		data.funnelStep = step
	end
end

-- Wins spent on something (frog, egg, trail). `item` is a short SKU.
function AnalyticsTracker.spend(player: Player, amount: number, balance: number, kind: string, item: string)
	pcall(function()
		AnalyticsService:LogEconomyEvent(
			player,
			Enum.AnalyticsEconomyFlowType.Sink,
			"Wins",
			amount,
			balance,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			`{kind}:{item}`
		)
	end)
end

function AnalyticsTracker.start()
	DataService.Changed:Connect(logFunnel)
end

return AnalyticsTracker
