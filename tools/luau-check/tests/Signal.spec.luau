local Signal = require("@shared/Util/Signal")
local t = require("@test")

t.test("handlers get the same table, not a copy", function()
	local signal = Signal.new()
	local data = { n = 1 }
	signal:Connect(function(received)
		received.n += 1
	end)
	signal:Fire(data)
	t.equal(data.n, 2)
end)

t.test("disconnect stops a handler", function()
	local signal = Signal.new()
	local calls = 0
	local connection = signal:Connect(function()
		calls += 1
	end)
	signal:Fire()
	connection:Disconnect()
	signal:Fire()
	t.equal(calls, 1)
end)

t.test("a handler error doesn't stop the others", function()
	local signal = Signal.new()
	local reached = false
	signal:Connect(function()
		error("boom")
	end)
	signal:Connect(function()
		reached = true
	end)
	signal:Fire()
	t.equal(reached, true)
end)
