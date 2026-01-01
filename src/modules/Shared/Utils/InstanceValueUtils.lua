local require = require(script.Parent.loader).load(script)

local Observable = require("Observable")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")

type ObjectValueClassName = "StringValue" | "NumberValue" | "BoolValue" | "ObjectValue"

--[[
	ValueContainer: A Folder containing value objects (NumberValue, StringValue, BoolValue, etc.)
	Used for storing collections like item counts, item lists, flags, etc.
]]

local InstanceValueUtils = {}
InstanceValueUtils.ServiceName = "InstanceValueUtils"

function InstanceValueUtils.updateInstanceValue<T>(
	parent: Instance,
	className: ObjectValueClassName,
	name: string,
	callback: (value: T) -> T
)
	local existingValue = InstanceValueUtils.getOrCreateInstanceValue(parent, className, name)
	local newValue = callback(existingValue.Value)
	existingValue.Value = newValue
end

--[[
	Get or create an instance value of the specified type.
]]
function InstanceValueUtils.getOrCreateInstanceValue<T>(parent: Instance, className: ObjectValueClassName, name: string): T
	local existingItemObject = parent:FindFirstChild(name)
	if existingItemObject and existingItemObject:IsA(className) then
		return existingItemObject :: T
	end

	local newItemObject = Instance.new(className)
	newItemObject.Name = name
	newItemObject.Parent = parent

	return newItemObject :: T
end

--[[
	Get the total count of all NumberValues in a ValueContainer (Folder).
]]
function InstanceValueUtils.getNumberValueSum(container: Folder): number
	local count = 0
	for _, child in container:GetChildren() do
		if not child:IsA("NumberValue") then
			continue
		end
		count += child.Value
	end
	return count
end

--[[
	Observe the total count of all NumberValues in a ValueContainer.
	Returns an Observable<number> that emits whenever any NumberValue changes.
]]
function InstanceValueUtils.observeNumberValueSum(container: Folder): Observable.Observable<number>
	return InstanceValueUtils.observeNumberValueCountBrio(container):Pipe({
		RxBrioUtils.emitOnDeath(0),
		Rx.startWith({ 0 }),
		Rx.distinct(),
	})
end

--[[
	Observe all NumberValues in a ValueContainer as Brio.
]]
function InstanceValueUtils.observeNumberValuesBrio(container: Folder)
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
		return child:IsA("NumberValue")
	end)
end

--[[
	Observe the total count of all NumberValues in a ValueContainer as Brio.
]]
function InstanceValueUtils.observeNumberValueCountBrio(container: Folder)
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
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

--[[
	Get a list of all StringValue names in a ValueContainer.
]]
function InstanceValueUtils.getStringValueList(container: Folder): { string }
	local list = {}
	for _, child in container:GetChildren() do
		if child:IsA("StringValue") then
			table.insert(list, child.Name)
		end
	end
	return list
end

--[[
	Observe a list of all StringValue names in a ValueContainer.
	Returns an Observable<{string}> that emits whenever StringValues are added/removed.
]]
function InstanceValueUtils.observeStringValueList(container: Folder): Observable.Observable<{ string }>
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
		return child:IsA("StringValue")
	end):Pipe({
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.switchMapBrio(function(stringValues: { StringValue })
			return Rx.of(stringValues):Pipe({
				Rx.map(function(values: { StringValue })
					local list = {}
					for _, stringValue in values do
						table.insert(list, stringValue.Name)
					end
					return list
				end),
			})
		end),
		RxBrioUtils.emitOnDeath({}),
		Rx.startWith({ {} }),
		Rx.distinct(),
	})
end

--[[
	Observe all StringValues in a ValueContainer as Brio.
]]
function InstanceValueUtils.observeStringValuesBrio(container: Folder)
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
		return child:IsA("StringValue")
	end)
end

--[[
	Get a map of all BoolValue states in a ValueContainer.
]]
function InstanceValueUtils.getBoolValueMap(container: Folder): { [string]: boolean }
	local map = {}
	for _, child in container:GetChildren() do
		if child:IsA("BoolValue") then
			map[child.Name] = child.Value
		end
	end
	return map
end

--[[
	Observe a map of all BoolValue states in a ValueContainer.
	Returns an Observable<{[string]: boolean}> that emits whenever BoolValues change.
]]
function InstanceValueUtils.observeBoolValueMap(container: Folder): Observable.Observable<{ [string]: boolean }>
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
		return child:IsA("BoolValue")
	end):Pipe({
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.switchMapBrio(function(boolValues: { BoolValue })
			local observables = {}
			for _, boolValue in boolValues do
				observables[boolValue.Name] = RxValueBaseUtils.observeValue(boolValue)
			end

			return RxBrioUtils.flatCombineLatest(observables):Pipe({
				Rx.map(function(state: { [string]: boolean })
					return state
				end),
			})
		end),
		RxBrioUtils.emitOnDeath({}),
		Rx.startWith({ {} }),
		Rx.distinct(),
	})
end

--[[
	Observe all BoolValues in a ValueContainer as Brio.
]]
function InstanceValueUtils.observeBoolValuesBrio(container: Folder)
	return RxInstanceUtils.observeChildrenBrio(container, function(child)
		return child:IsA("BoolValue")
	end)
end

return InstanceValueUtils
