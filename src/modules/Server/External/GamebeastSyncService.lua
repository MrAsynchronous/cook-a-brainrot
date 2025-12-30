local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")
local GamebeastService = require("GamebeastService")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

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
	self._maid:GiveTask(self._gamebeastService:ObserveConfig("ItemRarities"):Subscribe(function(itemRarities: any)
		self:_syncItemRarity(itemRarities)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Ingredients"):Subscribe(function(ingredients: any)
		self:_syncIngredient(ingredients)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("General"):Subscribe(function(generalSettings: any)
		self:_syncGeneralConfig(generalSettings)
	end))

	self._maid:GiveTask(self._gamebeastService:ObserveConfig("Backpacks"):Subscribe(function(backpacks: any)
		self:_syncBackpack(backpacks)
	end))
end

function GamebeastSyncService._syncItemRarity(self: GamebeastSyncService, gbRarities: { { Color: string } })
	for _, rarity in self._configService:GetItemRarities() do
		local gbRarity = gbRarities[rarity.Name]

		if gbRarity then
			rarity.Color.Value = Color3.fromHex(gbRarity.Color)
		end
	end
end

function GamebeastSyncService._syncIngredient(self: GamebeastSyncService, gbIngredients: { { Rarity: string } })
	for _, ingredient in self._configService:GetIngredients() do
		local gbIngredient = gbIngredients[ingredient.Name]

		if gbIngredient then
			ingredient.Rarity.Value = self._configService:GetRarity(gbIngredient.Rarity)
		end
	end
end

function GamebeastSyncService._syncGeneralConfig(self: GamebeastSyncService, gbSettings: { { [string]: any } })
	local settingContainer = self._configService:GetConfigContainer()

	for key, value in gbSettings do
		settingContainer:SetAttribute(key, value)
	end
end

function GamebeastSyncService._syncBackpack(self: GamebeastSyncService, gbBackpacks: { { Capacity: number } })
	for _, backpack in self._configService:GetBackpacks() do
		local gbBackpack = gbBackpacks[backpack.Name]

		if gbBackpack then
			backpack.Capacity.Value = gbBackpack.Capacity
		end
	end
end

return GamebeastSyncService
