local require = require(script.Parent.loader).load(script)

local AdorneeData = require("AdorneeData")

return AdorneeData.new({
	Name = "Slot1",
	PurchasePrice = 0,
	Locked = true,
	Stove = "None",
})
