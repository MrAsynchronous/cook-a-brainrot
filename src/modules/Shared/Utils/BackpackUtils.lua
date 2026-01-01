local require = require(script.Parent.loader).load(script)

local InstanceValueUtils = require("InstanceValueUtils")

local BackpackUtils = {}
BackpackUtils.ServiceName = "BackpackUtils"

function BackpackUtils.getEntityBackpack(entity: Instance): Model?
	for _, child in entity:GetChildren() do
		if child:IsA("Model") and child:HasTag("IngredientBackpack") then
			return child
		end
	end
	return nil
end

--[[
	Get the total count of items in a backpack's ValueContainer.
]]
function BackpackUtils.getContentCount(backpack: Model & { Items: Folder }): number
	return InstanceValueUtils.getNumberValueSum(backpack.Items)
end

--[[
	Observe the total count of items in a backpack's ValueContainer.
]]
function BackpackUtils.observeContentCount(backpack: Model & { Items: Folder })
	return InstanceValueUtils.observeNumberValueSum(backpack.Items)
end

--[[
	Observe all NumberValues in a backpack's ValueContainer as Brio.
]]
function BackpackUtils.observeContentsBrio(backpack: Model & { Items: Folder })
	return InstanceValueUtils.observeNumberValuesBrio(backpack.Items)
end

--[[
	Observe the total count of items in a backpack's ValueContainer as Brio.
]]
function BackpackUtils.observeContentCountBrio(backpack: Model & { Items: Folder })
	return InstanceValueUtils.observeNumberValueCountBrio(backpack.Items)
end

return BackpackUtils
