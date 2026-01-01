local require = require(script.Parent.loader).load(script)

local AdorneeData = require("AdorneeData")

return AdorneeData.new({
	DebugEnabled = false,
	DefaultBackpack = "",
	DefaultFridge = "",
	IngredientSpawnFrequency = 0,
})
