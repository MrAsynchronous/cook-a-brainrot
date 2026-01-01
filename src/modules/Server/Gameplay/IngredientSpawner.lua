local require = require(script.Parent.loader).load(script)

local Workspace = game:GetService("Workspace")

local Binder = require("Binder")
local ConfigService = require("ConfigService")
local DroppedIngredientData = require("DroppedIngredientData")
local GamebeastService = require("GamebeastService")
local Maid = require("Maid")
local Raycaster = require("Raycaster")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")
local SpawnerUtils = require("SpawnerUtils")
local ValueObject = require("ValueObject")

local LOOT_TABLE = {
	"Banana",
	"Watermelon",
	"Crab Shell",
	"Coconut",
}

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
		:GetGameConfig().IngredientSpawnFrequency
		:Observe()
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
	-- TODO: spawn varying amounts of ingredients and weight them by rarity

	for _, ingredientName in LOOT_TABLE do
		self:_spawnIngredient(ingredientName)

		task.wait(0.1)
	end
end

function IngredientSpawner._spawnIngredient(self: IngredientSpawner, ingredientName: string)
	local spawnLocation, _hitData = SpawnerUtils.getSpawnLocation(self._instance.SpawnArea, self._raycaster)

	local ingredientConfig = self._configService:GetIngredientConfig(ingredientName)
	local asset = self._configService:GetIngredientAsset(ingredientName):Clone()
	asset:PivotTo(CFrame.new(spawnLocation + Vector3.new(0, 5, 0)))
	asset:AddTag("DroppedIngredient")

	DroppedIngredientData:Set(asset, ingredientConfig.Value)

	asset.Parent = Workspace.Terrain

	self._gamebeastService:TrackEvent("IngredientSpawned", {
		IngredientName = ingredientName,
	})
end

function IngredientSpawner.Destroy(self: IngredientSpawner)
	self._maid:Destroy()
end

return Binder.new("IngredientSpawner", IngredientSpawner)
