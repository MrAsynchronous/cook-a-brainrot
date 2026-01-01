local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local ConfigService = require("ConfigService")
local DataStore = require("DataStore")
local IngredientBackpackData = require("IngredientBackpackData")
local Maid = require("Maid")
local PlayerDataStoreService = require("PlayerDataStoreService")
local RxBrioUtils = require("RxBrioUtils")
local RxCharacterUtils = require("RxCharacterUtils")
local RxPlayerUtils = require("RxPlayerUtils")
local ServiceBag = require("ServiceBag")

local BackpackService = {}
BackpackService.ServiceName = "BackpackService"

export type BackpackService = typeof(BackpackService) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,

	_configService: ConfigService.ConfigService,
	_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
}

function BackpackService.Init(self: BackpackService, serviceBag: ServiceBag.ServiceBag)
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)
	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)
end

function BackpackService.Start(self: BackpackService)
	self._maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
		local maid, player = brio:ToMaidAndValue()

		local equippedBackpack = AttributeValue.new(player, "EquippedBackpack")

		maid:GivePromise(
			self._playerDataStoreService:PromiseDataStore(player):Then(function(dataStore: DataStore.DataStore)
				local subStore = dataStore:GetSubStore(player.SaveSlot.Value) :: DataStore.DataStore

				local defaultBackpack = self._configService:GetGameConfig().DefaultBackpack.Value

				self._maid:GivePromise(
					subStore:Load("EquippedBackpack", defaultBackpack):Then(function(equippedBackpackName: string)
						equippedBackpack.Value = equippedBackpackName
					end)
				)

				self._maid:GiveTask(subStore:StoreOnValueChange("EquippedBackpack", equippedBackpack))
			end)
		)

		maid:GiveTask(equippedBackpack
			:ObserveBrio()
			:Pipe({
				RxBrioUtils.where(function(equippedBackpackName: string)
					return equippedBackpackName ~= nil
				end),
			})
			:Subscribe(function(brio)
				local maid, equippedBackpackName = brio:ToMaidAndValue()

				local backpackAsset = self._configService:GetBackpackAsset(equippedBackpackName):Clone()
				local backpackConfig = self._configService:GetBackpackConfig(equippedBackpackName)
				IngredientBackpackData:Set(backpackAsset, backpackConfig.Value)

				local backpackData = IngredientBackpackData:Create(backpackAsset)

				backpackAsset:AddTag("IngredientBackpack")

				maid:GiveTask(RxCharacterUtils.observeCharacter(player):Subscribe(function(character)
					if not character then
						return
					end

					backpackAsset.Parent = character
				end))

				-- track upstream config changes
				maid:GiveTask(backpackConfig:Observe():Subscribe(function(data)
					backpackData.Capacity.Value = data.Capacity
				end))
			end))
	end))
end

return BackpackService
