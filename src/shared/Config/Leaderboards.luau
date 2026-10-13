-- Global leaderboards shown on boards in every hub (OrderedDataStores).

local Game = require(script.Parent.Game)
local Lobby = require(script.Parent.Lobby)

export type Board = {
	id: string,
	title: string,
	suffix: string, -- after the number on each row
	color: Color3,
	value: (data: any) -> number, -- whole number written to the board
}

local Leaderboards = {}

Leaderboards.List = {
	{
		id = "Distance",
		title = "🏆 Best Distance",
		suffix = " m",
		color = Color3.fromRGB(255, 200, 40),
		value = function(data)
			return math.floor(Game.metersFor(data.bestDistance))
		end,
	},
	{
		id = "TimePlayed",
		title = "⏱ Time Played",
		suffix = " min",
		color = Color3.fromRGB(90, 200, 255),
		value = function(data)
			return math.floor(data.stats.timePlayed / 60)
		end,
	},
	{
		id = "RobuxSpent",
		title = "💎 Top Supporters",
		suffix = " R$",
		color = Color3.fromRGB(120, 255, 140),
		value = function(data)
			return math.floor(data.stats.robuxSpent)
		end,
	},
} :: { Board }

Leaderboards.StorePrefix = "FrogHop_Board_" -- + id + "_v1"
Leaderboards.Rows = 10
Leaderboards.RefreshSeconds = 60 -- write scores and re-read the top 10
Leaderboards.PlaytimeTick = 10 -- seconds between timePlayed updates

-- Local positions (inside each hub) of the boards, against the back wall.
function Leaderboards.position(index: number): Vector3
	return Lobby.board(index)
end

return Leaderboards
