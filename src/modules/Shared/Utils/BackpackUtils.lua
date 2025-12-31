local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")

local BackpackUtils = {}
BackpackUtils.ServiceName = "BackpackUtils"

function BackpackUtils.createBackpack(backpack: ConfigService.Backpack, contentType: string?): Model
	local backpackObject = backpack.Value:Clone()
	backpackObject.Name = "ItemBackpack"

	backpackObject:SetAttribute("BackpackName", backpack.Name)
	backpackObject:SetAttribute("ContentType", contentType)
	backpackObject:AddTag("ItemBackpack")

	return backpackObject
end

function BackpackUtils.getEntityBackpack(entity: Instance): Model?
	for _, child in entity:GetChildren() do
		if child:IsA("Model") and child:HasTag("ItemBackpack") then
			return child
		end
	end
	return nil
end

function BackpackUtils.getContentCount(backpack: Model & { Items: Folder }): number
	local count = 0
	for _, child in backpack.Items:GetChildren() do
		if not child:IsA("NumberValue") then
			continue
		end
		count += child.Value
	end
	return count
end

function BackpackUtils.observeContentCount(backpack: Model & { Items: Folder })
	return BackpackUtils.observeContentCountBrio(backpack):Pipe({
		RxBrioUtils.emitOnDeath(0),
		Rx.startWith({ 0 }),
		Rx.distinct(),
	})
end

function BackpackUtils.observeContentsBrio(backpack: Model & { Items: Folder })
	return RxInstanceUtils.observeChildrenBrio(backpack, function(child)
		return child:IsA("NumberValue")
	end)
end

function BackpackUtils.observeContentCountBrio(backpack: Model & { Items: Folder })
	return RxInstanceUtils.observeChildrenBrio(backpack.Items, function(child)
		return child:IsA("NumberValue")
	end):Pipe({
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.switchMapBrio(function(numberValues: { NumberValue })
			local observables = {}
			for _, numberValue in numberValues do
				observables[numberValue.Name] = RxValueBaseUtils.observeValue(numberValue)
			end

			return RxBrioUtils.flatCombineLatest(observables):Pipe({
				Rx.map(function(state: { [string]: number })
					local sum = 0
					for _, value in state do
						if typeof(value) == "number" then
							sum += value
						end
					end
					return sum
				end),
			})
		end),
	})
end

return BackpackUtils
