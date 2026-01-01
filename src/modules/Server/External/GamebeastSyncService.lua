local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")
local FridgeConfigData = require("FridgeConfigData")
local GamebeastService = require("GamebeastService")
local IngredientBackpackConfigData = require("IngredientBackpackConfigData")
local IngredientData = require("IngredientData")
local Maid = require("Maid")
local RarityConfigData = require("RarityConfigData")
local ServiceBag = require("ServiceBag")
local StoveConfigData = require("StoveConfigData")
local StoveSlotConfigData = require("StoveSlotConfigData")

local GamebeastSyncService = {}
GamebeastSyncService.ServiceName = "GamebeastSyncService"

export type GamebeastSyncService = typeof(GamebeastSyncService) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,

	_gamebeastService: GamebeastService.GamebeastService,
	_configService: ConfigService.ConfigService,
}

function GamebeastSyncService.Init(self: GamebeastSyncService, serviceBag: ServiceBag.ServiceBag)
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._gamebeastService = serviceBag:GetService(GamebeastService)
	self._configService = serviceBag:GetService(ConfigService)
end

function GamebeastSyncService.Start(self: GamebeastSyncService)
	self._maid:GiveTask(self._gamebeastService:ObserveConfig("General"):Subscribe(function(generalSettings: any)
		self:_syncGeneralConfig(generalSettings)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("ItemRarities"):Subscribe(function(itemRarities: any)
		self:_syncItemRarities(itemRarities)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Ingredients"):Subscribe(function(ingredients: any)
		self:_syncIngredients(ingredients)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Backpacks"):Subscribe(function(backpacks: any)
		self:_syncBackpacks(backpacks)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Fridges"):Subscribe(function(fridges: any)
		self:_syncFridges(fridges)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("StoveSlots"):Subscribe(function(stoveSlots: any)
		self:_syncStoveSlots(stoveSlots)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Stoves"):Subscribe(function(stoves: any)
		self:_syncStoves(stoves)
	end))
end

function GamebeastSyncService._syncGeneralConfig(self: GamebeastSyncService, gbSettings: { { [string]: any } })
	local gameConfigConfig = self._configService:GetGameConfig()

	for key, value in gbSettings do
		gameConfigConfig[key].Value = value
	end
end

function GamebeastSyncService._syncItemRarities(self: GamebeastSyncService, gbRarities: { { Color: string } })
	for rarityName, gbRarityData in gbRarities do
		if not RarityConfigData:IsData(gbRarityData) then
			warn(string.format("Invalid rarity data for %s", rarityName))

			continue
		end

		local rarityConfig = self._configService:GetRarityConfig(rarityName)
		if not rarityConfig then
			warn(string.format("Rarity data not found for %s", rarityName))

			continue
		end

		for key, value in gbRarityData do
			rarityConfig[key].Value = value
		end
	end
end

function GamebeastSyncService._syncIngredients(self: GamebeastSyncService, gbIngredients: { { Rarity: string } })
	for ingredientName, gbIngredientData in gbIngredients do
		if not IngredientData:IsData(gbIngredientData) then
			warn(string.format("Invalid ingredient data for %s", ingredientName))

			continue
		end

		local ingredientConfig = self._configService:GetIngredientConfig(ingredientName)
		if not ingredientConfig then
			warn(string.format("Ingredient data not found for %s", ingredientName))

			continue
		end

		for key, value in gbIngredientData do
			ingredientConfig[key].Value = value
		end
	end
end

function GamebeastSyncService._syncBackpacks(self: GamebeastSyncService, gbBackpacks: { { Capacity: number } })
	for backpackName, gbBackpackData in gbBackpacks do
		if not IngredientBackpackConfigData:IsData(gbBackpackData) then
			warn(string.format("Invalid backpack data for %s", backpackName))

			continue
		end

		local backpackConfig = self._configService:GetBackpackConfig(backpackName)
		if not backpackConfig then
			warn(string.format("Backpack data not found for %s", backpackName))

			continue
		end

		for key, value in gbBackpackData do
			backpackConfig[key].Value = value
		end
	end
end

function GamebeastSyncService._syncFridges(self: GamebeastSyncService, gbFridges: { { Capacity: number } })
	for fridgeName, gbFridgeData in gbFridges do
		if not FridgeConfigData:IsData(gbFridgeData) then
			warn(string.format("Invalid fridge data for %s", fridgeName))

			continue
		end

		local fridgeConfig = self._configService:GetFridgeConfig(fridgeName)
		if not fridgeConfig then
			warn(string.format("Fridge data not found for %s", fridgeName))

			continue
		end

		for key, value in gbFridgeData do
			fridgeConfig[key].Value = value
		end
	end
end

function GamebeastSyncService._syncStoves(self: GamebeastSyncService, gbStoves: { { Name: string } })
	for stoveName, gbStoveConfig in gbStoves do
		if not StoveConfigData:IsData(gbStoveConfig) then
			warn(string.format("Invalid stove config for %s", stoveName))
		end

		local stoveConfig = self._configService:GetStoveConfig(stoveName)
		if not stoveConfig then
			warn(string.format("Stove data not found for %s", stoveName))

			continue
		end

		for key, value in gbStoveConfig do
			stoveConfig[key].Value = value
		end
	end
end

function GamebeastSyncService._syncStoveSlots(
	self: GamebeastSyncService,
	gbStoveSlots: { { Stove: string, Brainrot: string } }
)
	for stoveSlotName, gbStoveSlotConfig in gbStoveSlots do
		if not StoveSlotConfigData:IsData(gbStoveSlotConfig) then
			warn(string.format("Invalid stove slot config for %s", stoveSlotName))

			continue
		end

		local stoveSlotConfig = self._configService:GetStoveSlotConfig(stoveSlotName)
		if not stoveSlotConfig then
			warn(string.format("Stove slot data not found for %s", stoveSlotName))

			continue
		end

		for key, value in gbStoveSlotConfig do
			stoveSlotConfig[key].Value = value
		end
	end
end

return GamebeastSyncService
