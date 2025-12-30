local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local ShopItem = {}
ShopItem.__index = ShopItem
ShopItem.ServiceName = "ShopItem"

export type ShopItem = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,
		_instance: Model,
		_itemName: AttributeValue.AttributeValue<string>,
	},
	ShopItem
))

function ShopItem.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, ShopItem) :: ShopItem
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._instance = assert(instance, "No instance")

	self._itemName = AttributeValue.new(self._instance, "ItemName")

	self._prompt = Instance.new("ProximityPrompt")
	self._prompt.Parent = self._instance.PrimaryPart
	self._prompt.ActionText = "Purchase"
	self._prompt.ObjectText = self._itemName.Value
	self._prompt.RequiresLineOfSight = false
	self._prompt.MaxActivationDistance = 8
	self._prompt.HoldDuration = 1.5

	self._maid:GiveTask(self._prompt)
	self._maid:GiveTask(self._prompt.Triggered:Connect(function(player)
		print(player.Name, "wants to purchase the shop item")
	end))

	return self
end

function ShopItem.Destroy(self: ShopItem)
	self._maid:Destroy()
end

return Binder.new("ShopItem", ShopItem)
