local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Binder = require("Binder")
local ItemService = require("ItemService")
local SpawnerUtils = require("SpawnerUtils")
local Raycaster = require("Raycaster")
local GamebeastService = require("GamebeastService")
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local RxAttributeUtils = require("RxAttributeUtils")

local IngredientSpawner = {}
IngredientSpawner.__index = IngredientSpawner
IngredientSpawner.ServiceName = "IngredientSpawner"

export type IngredientSpawner = typeof(setmetatable(
	{} :: {
        _serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,
        _instance: Model & {
            SpawnArea: Part,
            PrimaryPart: Part
        },
        _itemService: ItemService.ItemService,
        _spawnFrequency: ValueObject.ValueObject<number>,
        _raycaster: Raycaster.Raycaster,
        _gamebeastService: GamebeastService.GamebeastService
	},
	{} :: typeof({ __index = IngredientSpawner })
))

function IngredientSpawner.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
    local self = setmetatable({}, IngredientSpawner)
    self._serviceBag = assert(serviceBag, "No service bag")
    self._maid = Maid.new()

    self._itemService = serviceBag:GetService(ItemService)
    self._gamebeastService = serviceBag:GetService(GamebeastService)
    self._generalConfig = self._itemService:GetGeneralConfig()

    self._instance = assert(instance, "No instance")

    self._raycaster = Raycaster.new(function(hitData)
        return not hitData.Part.CanCollide
    end)

    self._maid:GiveTask(RxAttributeUtils.observeAttribute(self._generalConfig, "IngredientSpawnFrequency"):Pipe({
        Rx.switchMap(function(frequency: number)
            return Rx.timer(0, frequency)
        end)
    }):Subscribe(function()
        self:SpawnIngredientsAsync()
    end))

    return self
end

function IngredientSpawner.SpawnIngredientsAsync(self: IngredientSpawner)
    local ingredients = self._itemService:GetIngredients()
    
    -- TODO: spawn varying amounts of ingredients and weight them by rarity

    for _, ingredient in ingredients do
        self:_spawnIngredient(ingredient)

        task.wait(0.1)
    end
end

function IngredientSpawner._spawnIngredient(self: IngredientSpawner, ingredient: ItemService.Ingredient)
    local spawnLocation, _hitData = SpawnerUtils.getSpawnLocation(
        self._instance.SpawnArea,
        self._raycaster
    )

    local ingredientObject = ingredient.Value:Clone()
    ingredientObject.Parent = self._itemService:GetDroppedIngredientsFolder()
    ingredientObject:PivotTo(CFrame.new(spawnLocation + Vector3.new(0, 5, 0)))
    ingredientObject:SetAttribute("IngredientName", ingredient.Name)
    ingredientObject:AddTag("DroppedIngredient")

    self._gamebeastService:TrackEvent("IngredienetSpawned", {
        IngredientName = ingredient.Name,
    })
end

function IngredientSpawner.Destroy(self: IngredientSpawner)
    self._maid:Destroy()
end

return Binder.new("IngredientSpawner", IngredientSpawner)