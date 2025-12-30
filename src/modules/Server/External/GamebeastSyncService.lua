local require = require(script.Parent.loader).load(script)

local GamebeastService = require("GamebeastService")
local ItemService = require("ItemService")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local GamebeastSyncService = {}
GamebeastSyncService.ServiceName = "GamebeastSyncService"

export type GamebeastSyncService = typeof(GamebeastSyncService) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,

	_gamebeastService: GamebeastService.GamebeastService,
	_itemService: ItemService.ItemService,
}

function GamebeastSyncService.Init(self: GamebeastSyncService, serviceBag: ServiceBag.ServiceBag)
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._gamebeastService = serviceBag:GetService(GamebeastService)
	self._itemService = serviceBag:GetService(ItemService)
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
end

function GamebeastSyncService._syncItemRarity(self: GamebeastSyncService, gbRarities: { { Color: string } })
	for _, rarity in self._itemService:GetItemRarities() do
		local gbRarity = gbRarities[rarity.Name]

		if gbRarity then
			rarity.Color.Value = Color3.fromHex(gbRarity.Color)
		end
	end
end

function GamebeastSyncService._syncIngredient(self: GamebeastSyncService, gbIngredients: { { Rarity: string } })
	for _, ingredient in self._itemService:GetIngredients() do
		local gbIngredient = gbIngredients[ingredient.Name]

		if gbIngredient then
			ingredient.Rarity.Value = self._itemService:GetRarity(gbIngredient.Rarity)
		end
	end
end

function GamebeastSyncService._syncGeneralConfig(self: GamebeastSyncService, gbSettings: { { [string]: any } })
	local settingContainer = self._itemService:GetGeneralConfig()

	for key, value in gbSettings do
		settingContainer:SetAttribute(key, value)
	end
end

return GamebeastSyncService
