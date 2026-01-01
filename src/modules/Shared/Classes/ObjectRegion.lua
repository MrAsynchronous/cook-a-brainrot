local require = require(script.Parent.loader).load(script)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Brio = require("Brio")
local Maid = require("Maid")
local Observable = require("Observable")
local ObservableSet = require("ObservableSet")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

local ObjectRegion = {}
ObjectRegion.__index = ObjectRegion
ObjectRegion.ServiceName = "ObjectRegion"

export type ObjectRegion = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_regionPart: BasePart,
		_overlapParams: OverlapParams?,
		_objects: ObservableSet.ObservableSet<Instance>,
		_filter: (Instance) -> Instance?,

		ItemAdded: Signal.Signal,
		ItemRemoved: Signal.Signal,
	},
	ObjectRegion
))

--[=[
	Creates a new ObjectRegion that monitors a region for objects matching a filter.

	@param serviceBag ServiceBag.ServiceBag
	@param regionPart BasePart -- The part that defines the region bounds
	@param filter (Instance) -> Instance? -- Function that filters parts and returns the object to track, or nil
	@param overlapParams OverlapParams? -- Optional overlap parameters for filtering parts
	@return ObjectRegion
]=]
function ObjectRegion.new(
	serviceBag: ServiceBag.ServiceBag,
	regionPart: BasePart,
	filter: (Instance) -> Instance?,
	overlapParams: OverlapParams?
)
	local self = setmetatable({}, ObjectRegion)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._regionPart = assert(regionPart, "No region part")
	self._overlapParams = overlapParams
	self._filter = assert(filter, "No filter function")

	self._objects = ObservableSet.new()
	self._maid:GiveTask(self._objects)

	self.ItemAdded = self._objects.ItemAdded
	self.ItemRemoved = self._objects.ItemRemoved

	-- Track currently detected objects to efficiently detect items leaving
	local currentObjects: { [Instance]: boolean } = {}

	self._maid:GiveTask(RunService.Heartbeat:Connect(function()
		local parts =
			Workspace:GetPartBoundsInBox(self._regionPart:GetPivot(), self._regionPart.Size, self._overlapParams)

		-- Track objects found in this frame
		local foundObjects: { [Instance]: boolean } = {}

		-- Process all parts found in the region
		for _, part in parts do
			local filteredPart = self._filter(part)
			if not filteredPart then
				continue
			end

			foundObjects[filteredPart] = true

			-- Add to observable set if not already present
			if not currentObjects[filteredPart] then
				currentObjects[filteredPart] = true
				self._objects:Add(filteredPart)
			end
		end

		-- Remove objects that are no longer in the region
		for object, _ in currentObjects do
			if not foundObjects[object] then
				currentObjects[object] = nil
				self._objects:Remove(object)
			end
		end
	end))

	return self
end

--[=[
	Observes the list of objects currently in the region.
	Emits a new list whenever objects enter or leave the region.

	@return Observable<{ Instance }>
]=]
function ObjectRegion.ObserveObjectsInRegion(self: ObjectRegion): Observable.Observable<{ Instance }>
	return Observable.new(function(sub)
		if not self._objects then
			return sub:Fail("ObjectRegion is already destroyed")
		end

		local maid = Maid.new()

		-- Emit initial list
		sub:Fire(self._objects:GetList())

		-- Track the current list state
		local currentList = self._objects:GetList()

		-- Subscribe to item added/removed to rebuild and emit the list
		maid:GiveTask(self._objects.ItemAdded:Connect(function()
			currentList = self._objects:GetList()
			sub:Fire(currentList)
		end))

		maid:GiveTask(self._objects.ItemRemoved:Connect(function()
			currentList = self._objects:GetList()
			sub:Fire(currentList)
		end))

		maid:GiveTask(function()
			sub:Complete()
		end)

		return maid
	end) :: any
end

--[=[
	Observes objects in the region as Brios. Each object gets its own Brio that is
	automatically cleaned up when the object leaves the region.

	@return Observable<Brio<Instance>>
]=]
function ObjectRegion.ObserveObjectsInRegionBrio(self: ObjectRegion): Observable.Observable<Brio.Brio<Instance>>
	if not self._objects then
		return Observable.new(function(sub)
			sub:Fail("ObjectRegion is already destroyed")
		end)
	end

	return self._objects:ObserveItemsBrio()
end

function ObjectRegion.Destroy(self: ObjectRegion)
	self._maid:Destroy()
end

return ObjectRegion
