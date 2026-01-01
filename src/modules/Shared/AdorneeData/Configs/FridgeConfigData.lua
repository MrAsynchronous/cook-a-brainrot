local require = require(script.Parent.loader).load(script)

local AdorneeData = require("AdorneeData")

return AdorneeData.new({
	Name = "Fridge",
	Capacity = 0,
})
