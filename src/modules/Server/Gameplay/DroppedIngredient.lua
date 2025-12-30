local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local ItemService = require("ItemService")
local AttributeValue = require("AttributeValue")
local ModelUtils = require("ModelUtils")
local Blend = require("Blend")
local GamebeastService = require("GamebeastService")

local DroppedIngredient = {}
DroppedIngredient.__index = DroppedIngredient
DroppedIngredient.ServiceName = "DroppedIngredient"

export type DroppedIngredient = typeof(DroppedIngredient) & {
    _serviceBag: ServiceBag.ServiceBag,
    _maid: Maid.Maid,
    _instance: Instance,
    _itemService: ItemService.ItemService,
    _gamebeastService: GamebeastService.GamebeastService
}

function DroppedIngredient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
    local self = setmetatable({}, DroppedIngredient)

    self._serviceBag = assert(serviceBag, "No service bag")
    self._maid = Maid.new()

    self._itemService = serviceBag:GetService(ItemService)
    self._gamebeastService = serviceBag:GetService(GamebeastService)

    self._instance = assert(instance, "No instance")
    self._ingredientName = AttributeValue.new(self._instance, "IngredientName")

    self._ingredient = self._itemService:GetIngredient(self._ingredientName.Value)

    self._proximityPromptRender = Blend.New "ProximityPrompt" {
        ActionText = "Pickup",
        ObjectText = self._ingredientName.Value,
        RequiresLineOfSight = false,

        [Blend.OnEvent "Triggered"] = function(player: Player)
            self._gamebeastService:TrackUserEvent(player, "IngredientCollected", {
                IngredientName = self._ingredientName.Value,
            })

            local playerPlot = player:FindFirstChild("Plot").Value
            if (not playerPlot) then
                return
            end

            local pantry = playerPlot:FindFirstChild("Pantry")

            local newIngredient = self._ingredient:Clone()
            newIngredient.Parent = pantry
        end
    }

    self._maid:GiveTask(self._proximityPromptRender:Subscribe(function(prompt: ProximityPrompt)
        prompt.Parent = self._instance
    end))

    ModelUtils.setModelAnchored(self._instance, false)

    return self
end

function DroppedIngredient.Destroy(self: DroppedIngredient)
    self._maid:Destroy()
end

return Binder.new("DroppedIngredient", DroppedIngredient)