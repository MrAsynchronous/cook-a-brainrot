local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local BackpackUtils = require("BackpackUtils")
local ConfigService = require("ConfigService")
local DataStore = require("DataStore")
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

		local playerBackpackReference = Instance.new("ObjectValue")
		playerBackpackReference.Name = "CurrentBackpack"
		playerBackpackReference.Parent = player

		maid:GivePromise(
			self._playerDataStoreService:PromiseDataStore(player):Then(function(dataStore: DataStore.DataStore)
				local subStore = dataStore:GetSubStore(player.SaveSlot.Value) :: DataStore.DataStore

				self._maid:GivePromise(
					subStore
						:Load("EquippedBackpack", self._configService:GetGeneralConfigValue("DefaultBackpack"))
						:Then(function(equippedBackpackName: string)
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

				local backpackConfig = self._configService:GetBackpack(equippedBackpackName)
				local backpack = BackpackUtils.createBackpack(backpackConfig, "Ingredient")
				playerBackpackReference.Value = backpack

				maid:GiveTask(backpack)
			end))

		maid:GiveTask(RxCharacterUtils.observeCharacterBrio(player):Subscribe(function(brio)
			local maid, character = brio:ToMaidAndValue()

			playerBackpackReference.Value.Parent = character
		end))
	end))
end

return BackpackService
