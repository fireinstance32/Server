-- Every pet feature by name: Face (eyes, snouts, mouths), Head (ears, horns,
-- antennae) and Body (tails, wings, shells, special bodies).

local features: { [string]: (any, ...any) -> () } = {}
for _, group in { require(script.Face), require(script.Head), require(script.Body) } :: { any } do
	for name, fn in group do
		features[name] = fn
	end
end
return features
