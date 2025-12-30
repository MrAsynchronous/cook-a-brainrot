local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local ConfigService = require("ConfigService")
local GamebeastService = require("GamebeastService")
local Maid = require("Maid")
local Raycaster = require("Raycaster")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")
local SpawnerUtils = require("SpawnerUtils")
local ValueObject = require("ValueObject")

local IngredientSpawner = {}
IngredientSpawner.__index = IngredientSpawner
IngredientSpawner.ServiceName = "IngredientSpawner"

export type IngredientSpawner = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,
		_gamebeastService: GamebeastService.GamebeastService,

		_instance: Model & {
			SpawnArea: Part,
			PrimaryPart: Part,
		},
		_spawnFrequency: ValueObject.ValueObject<number>,
		_raycaster: Raycaster.Raycaster,
	},
	IngredientSpawner
))

function IngredientSpawner.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, IngredientSpawner) :: IngredientSpawner
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)

	self._instance = assert(instance, "No instance")

	self._raycaster = Raycaster.new(function(hitData)
		return not hitData.Part.CanCollide
	end)

	self._maid:GiveTask(self._configService
		:ObserveGeneralConfig("IngredientSpawnFrequency")
		:Pipe({
			Rx.switchMap(function(frequency: number)
				return Rx.timer(0, frequency)
			end),
		})
		:Subscribe(function()
			self:SpawnIngredientsAsync()
		end))

	return self
end

function IngredientSpawner.SpawnIngredientsAsync(self: IngredientSpawner)
	local ingredients = self._configService:GetIngredients()

	-- TODO: spawn varying amounts of ingredients and weight them by rarity

	for _, ingredient in ingredients do
		self:_spawnIngredient(ingredient)

		task.wait(0.1)
	end
end

function IngredientSpawner._spawnIngredient(self: IngredientSpawner, ingredient: ConfigService.Ingredient)
	local spawnLocation, _hitData = SpawnerUtils.getSpawnLocation(self._instance.SpawnArea, self._raycaster)

	local ingredientObject = ingredient.Value:Clone()
	ingredientObject.Parent = self._configService:GetDroppedIngredientsFolder()
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
