local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")

local FridgeUtils = {}
FridgeUtils.ServiceName = "FridgeUtils"

function FridgeUtils.createFridge(fridge: ConfigService.Fridge): Model
	local fridgeObject = fridge.Value:Clone()
	fridgeObject.Name = "Fridge"

	fridgeObject:SetAttribute("FridgeName", fridge.Name)
	fridgeObject:AddTag("Fridge")

	return fridgeObject
end

return FridgeUtils
