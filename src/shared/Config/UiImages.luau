--!strict
-- Roblox image ids for the interface (assets/textures/ui). Upload the PNG,
-- paste its id here. 0 = not uploaded yet: icons fall back to emoji and
-- panels go without studs. The UI preview tool draws the local PNGs instead.

local UiImages = {}

UiImages.Ids = {
	icons = 0, -- icons.png + icons2.png: the icon sheets (layout in Config/IconAtlas)
	icons2 = 0,
	studs = 0, -- studs.png: tiling brick-stud texture for panels
	pets = 0, -- pets.png: every pet's picture (layout in Config/PetIconAtlas)
	frogs = 0, -- frogs.png: every frog's picture (layout in Config/FrogIconAtlas)
} :: { [string]: number }

-- Emoji shown until the icon sheet is uploaded.
UiImages.Fallback = {
	shop = "🛒",
	rebirth = "🔁",
	pets = "🐾",
	trails = "✨",
	inventory = "🎒",
	gifts = "🎁",
	daily = "📅",
	bolt = "⚡",
	trophy = "🏆",
	frog = "🐸",
	starter = "🎉",
	potion_hops = "🧪",
	potion_wins = "🧪",
	potion_luck = "🧪",
	egg = "🥚",
	lock = "🔒",
	plus = "➕",
	close = "✖",
	star = "⭐",
	settings = "⚙",
	pumpkin = "🎃",
	candy_corn = "🍬",
	crown = "👑",
	portal = "🌀",
	book = "📖",
	ticket = "🎟",
	globe = "🌍",
	music = "🎵",
	speaker = "🔊",
	boost = "⭐",
	check = "✅",
	info = "ℹ",
	sort = "↕",
	title = "🎖",
	trash = "🗑",
	robux = "\u{E002}",
	coin = "🪙",
	gem = "💎",
	hourglass = "⏳",
	clock = "⏰",
	shield = "🛡",
	sparkle = "✨",
	auto = "🔄",
	friends = "👥",
	add_friend = "➕",
	gamepass = "🎫",
	arrow_right = "➡",
	upgrade = "⬆",
	codes = "🎟",
	luck = "🍀",
	heart = "❤",
	exclamation = "❗",
	warning = "⚠",
	mouse = "🖱",
	fire = "🔥",
	rocket = "🚀",
	egg_golden = "🥚",
	egg_rainbow = "🥚",
	egg_cracked = "🐣",
	trophy_silver = "🥈",
	trophy_bronze = "🥉",
	music_off = "🔇",
	speaker_off = "🔈",
	minus = "➖",
	search = "🔍",
	star3 = "🌟",
	house = "🏠",
	teleport = "🌀",
	pet = "🐶",
	ghost = "👻",
	candy = "🍬",
	lucky_block = "❓",
} :: { [string]: string }

-- "rbxassetid://..." for an uploaded image, or nil.
function UiImages.content(name: string): string?
	local id = UiImages.Ids[name]
	if id and id ~= 0 then
		return `rbxassetid://{id}`
	end
	if (_G :: any).__UI_PREVIEW then
		return `local:{name}` -- tools/ui-preview draws assets/textures/ui/<name>.png
	end
	return nil
end

return UiImages
