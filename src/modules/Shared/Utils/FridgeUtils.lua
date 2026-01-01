local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")

local FridgeUtils = {}
FridgeUtils.ServiceName = "FridgeUtils"

function FridgeUtils.createFridgeAsset(fridge: ConfigService.Fridge): Model
	local fridgeObject = fridge.Value:Clone()
	fridgeObject.Name = "Fridge"

	return fridgeObject
end

return FridgeUtils
