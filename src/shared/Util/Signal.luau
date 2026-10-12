--!strict
-- Minimal Luau signal. Unlike a BindableEvent it passes arguments through
-- untouched, so handlers get the real tables (a BindableEvent copies them,
-- and edits to the copy are lost). Each handler starts right away in its own
-- thread (task.spawn), so one that yields or errors doesn't hold up the rest.

export type Connection = { Disconnect: (Connection) -> () }
export type Signal = {
	Connect: (Signal, (...any) -> ()) -> Connection,
	Fire: (Signal, ...any) -> (),
}

local Signal = {}

-- task.spawn in Roblox; a protected call where `task` doesn't exist (tests).
local spawner: any = if typeof(task) == "table" then (task :: any).spawn else nil

local function run(handler: (...any) -> (), ...: any)
	if spawner then
		(spawner :: any)(handler, ...)
		return
	end
	local ok, err = pcall(handler, ...)
	if not ok then
		print(`Signal handler error: {err}`)
	end
end

function Signal.new(): Signal
	local handlers: { (...any) -> () } = {}
	local signal = {}

	function signal.Connect(_self, handler: (...any) -> ()): Connection
		table.insert(handlers, handler)
		local connection = {}
		function connection.Disconnect(_conn)
			local index = table.find(handlers, handler)
			if index then
				table.remove(handlers, index)
			end
		end
		return connection :: any
	end

	function signal.Fire(_self, ...: any)
		-- Copy first so handlers may connect/disconnect while firing.
		for _, handler in table.clone(handlers) do
			run(handler, ...)
		end
	end

	return signal :: any
end

return Signal
