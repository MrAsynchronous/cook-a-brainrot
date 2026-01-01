local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local BackpackUtils = require("BackpackUtils")
local Binder = require("Binder")
local Blend = require("Blend")
local ConfigService = require("ConfigService")
local DroppedIngredientData = require("DroppedIngredientData")
local GamebeastService = require("GamebeastService")
local IngredientBackpack = require("IngredientBackpack")
local Maid = require("Maid")
local ModelUtils = require("ModelUtils")
local PlayerUtils = require("PlayerUtils")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")

local DroppedIngredient = {}
DroppedIngredient.__index = DroppedIngredient
DroppedIngredient.ServiceName = "DroppedIngredient"

export type DroppedIngredient = typeof(DroppedIngredient) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,

	_configService: ConfigService.ConfigService,
	_gamebeastService: GamebeastService.GamebeastService,

	_instance: Instance,
	_ingredientName: AttributeValue.AttributeValue<string>,
	_ingredient: ConfigService.Ingredient,
	_IngredientBackpackBinder: Binder.Binder<IngredientBackpack.IngredientBackpack>,
	_collected: AttributeValue.AttributeValue<boolean>,

	_data: any,
}

function DroppedIngredient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, DroppedIngredient)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)
	self._IngredientBackpackBinder = serviceBag:GetService(IngredientBackpack)

	self._instance = assert(instance, "No instance")

	self._data = DroppedIngredientData:Create(self._instance)

	self._proximityPromptRender = Blend.New "ProximityPrompt" {
		ActionText = "Pickup",
		ObjectText = self._data.Name.Value,
		RequiresLineOfSight = false,
		Enabled = self._data.Collected:Observe():Pipe({
			Rx.map(function(collected: boolean)
				return not collected
			end),
		}),

		[Blend.OnEvent "Triggered"] = function(player: Player)
			if self._data.Collected.Value then
				return
			end

			self._data.Collected.Value = true

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
	self._gamebeastService:TrackPlayerEvent(player, "IngredientCollected", {
		IngredientName = self._data.Name.Value,
	})

	local playerPlot = PlayerUtils.getPlayerPlot(player)
	if not playerPlot then
		return self._gamebeastService:TrackPlayerEventDebug(player, "NoPlayerPlot", {
			action = "IngredientCollected",
		})
	end

	local character = player.Character
	local backpackAsset = BackpackUtils.getEntityBackpack(character)
	local backpack = self._IngredientBackpackBinder:Get(backpackAsset)

	local added = backpack:AddItem(self._instance)

	if added then
		self._instance:Destroy()
	else
		self._data.Collected.Value = false
	end
end

function DroppedIngredient.Destroy(self: DroppedIngredient)
	self._maid:Destroy()
end

return Binder.new("DroppedIngredient", DroppedIngredient)
