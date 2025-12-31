local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Maid = require("Maid")
local ObservableSet = require("ObservableSet")
local ServiceBag = require("ServiceBag")

local ObjectRegion = {}
ObjectRegion.__index = ObjectRegion
ObjectRegion.ServiceName = "ObjectRegion"

export type ObjectRegion = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_regionPart: BasePart,
		_overlapParams: OverlapParams?,
	},
	ObjectRegion
))

function ObjectRegion.new(serviceBag: ServiceBag.ServiceBag, regionPart: BasePart, filter: (Instance) -> Instance)
	local self = setmetatable({}, ObjectRegion)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._regionPart = assert(regionPart, "No region part")

	self._objects = self._maid:GiveTask(ObservableSet.new())
	self._filter = filter

	self._maid:GiveTask(RunService.Heartbeat:Connect(function()
		local parts =
			Workspace:GetPartBoundsInBox(self._regionPart:GetPivot(), self._regionPart.Size, self._overlapParams)

		for _, part in parts do
			local filteredPart = self._filter(part)
			if not filteredPart then
				continue
			end

			self._objects:Add(filteredPart)
		end
	end))

	return self
end

function ObjectRegion.ObserveObjectsInRegion(self: ObjectRegion) end

function ObjectRegion.ObserveObjectsInRegionBrio(self: ObjectRegion) end

function ObjectRegion.Destroy(self: ObjectRegion)
	self._maid:Destroy()
end

return ObjectRegion
