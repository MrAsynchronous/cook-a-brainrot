local require = require(script.Parent.loader).load(script)

local AdorneeData = require("AdorneeData")

return AdorneeData.new({
	Name = "Ingredient",
	Rarity = "Common",
	Collected = false,
	CanBeCollected = false,
})
