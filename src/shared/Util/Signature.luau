--!strict
-- Cheap change detection for UI that rebuilds from data snapshots (the
-- server pushes one every few hundred ms while training). Signature.of turns
-- plain values into a stable string (table keys sorted); Signature.guard
-- wraps a render so it only runs when its key string changes.

local Signature = {}

local function write(value: any, out: { string })
	local kind = type(value)
	if kind == "table" then
		local keys = {}
		for key in value do
			table.insert(keys, key)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		table.insert(out, "{")
		for _, key in keys do
			write(key, out)
			table.insert(out, "=")
			write(value[key], out)
			table.insert(out, ",")
		end
		table.insert(out, "}")
	elseif kind == "string" then
		table.insert(out, string.format("%q", value))
	else
		table.insert(out, tostring(value))
	end
end

-- Stable string for the given values (nil-safe, order-independent keys).
function Signature.of(...: any): string
	local args = table.pack(...)
	local out = {}
	for i = 1, args.n do
		write(args[i], out)
		table.insert(out, ";")
	end
	return table.concat(out)
end

-- Returns a function that calls render(data) only when key(data) differs
-- from the previous call's key. The key may read local UI state too (a sort
-- mode, a toggle), so changing that and calling again re-renders.
function Signature.guard<T>(key: (T) -> string, render: (T) -> ()): (T) -> ()
	local last: string? = nil
	return function(data: T)
		local current = key(data)
		if current ~= last then
			last = current
			render(data)
		end
	end
end

return Signature
