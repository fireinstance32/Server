-- ModuleScript shared by server and client (ReplicatedStorage.Shared.Hello)
local Hello = {}

function Hello.greet(name: string): string
	return `Hello, {name}!`
end

return Hello
