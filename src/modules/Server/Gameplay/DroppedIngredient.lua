local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local Blend = require("Blend")
local GamebeastService = require("GamebeastService")
local ItemService = require("ItemService")
local Maid = require("Maid")
local ModelUtils = require("ModelUtils")
local PlayerRestaurant = require("PlayerRestaurant")
local ServiceBag = require("ServiceBag")

local DroppedIngredient = {}
DroppedIngredient.__index = DroppedIngredient
DroppedIngredient.ServiceName = "DroppedIngredient"

export type DroppedIngredient = typeof(DroppedIngredient) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,
	_instance: Instance,
	_itemService: ItemService.ItemService,
	_gamebeastService: GamebeastService.GamebeastService,
	_playerRestaurant: Binder.Binder<PlayerRestaurant.PlayerRestaurant>,
	_ingredientName: AttributeValue.AttributeValue<string>,
	_ingredient: ItemService.Ingredient,
}

function DroppedIngredient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, DroppedIngredient)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._itemService = serviceBag:GetService(ItemService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)
	self._playerRestaurant = serviceBag:GetService(PlayerRestaurant)

	self._instance = assert(instance, "No instance")
	self._ingredientName = AttributeValue.new(self._instance, "IngredientName")
	self._collected = AttributeValue.new(self._instance, "Collected", false)

	self._ingredient = self._itemService:GetIngredient(self._ingredientName.Value)

	self._proximityPromptRender = Blend.New "ProximityPrompt" {
		ActionText = "Pickup",
		ObjectText = self._ingredientName.Value,
		RequiresLineOfSight = false,

		[Blend.OnEvent "Triggered"] = function(player: Player)
			if self._collected.Value then
				return
			end

			self._collected.Value = true

			return self:_collectIngredient(player)
		end,
	}

	self._maid:GiveTask(self._proximityPromptRender:Subscribe(function(prompt: ProximityPrompt)
		prompt.Parent = self._instance
	end))

	ModelUtils.setModelAnchored(self._instance, false)

	return self
end

function DroppedIngredient._collectIngredient(self: DroppedIngredient, player: Player)
	self._gamebeastService:TrackUserEvent(player, "IngredientCollected", {
		IngredientName = self._ingredientName.Value,
	})

	local playerPlot = player:FindFirstChild("Plot").Value
	if not playerPlot then
		return
	end

	local pantry = playerPlot:FindFirstChild("Pantry")

	local newIngredient = self._ingredient:Clone()
	newIngredient.Parent = pantry
end

function DroppedIngredient.Destroy(self: DroppedIngredient)
	self._maid:Destroy()
end

return Binder.new("DroppedIngredient", DroppedIngredient)
