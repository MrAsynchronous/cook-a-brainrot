local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local Fridge = {}
Fridge.__index = Fridge
Fridge.ServiceName = "Pantry"

export type Fridge = typeof(Fridge) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,
}

function Fridge.new(serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, Fridge)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	return self
end

function Fridge.Destroy(self: Fridge)
	self._maid:Destroy()
end

return Fridge
