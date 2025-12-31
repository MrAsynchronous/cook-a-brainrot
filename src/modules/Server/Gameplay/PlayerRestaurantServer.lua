local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local DataStore = require("DataStore")
local FridgeUtils = require("FridgeUtils")
local GamebeastService = require("GamebeastService")
local ObjectRegion = require("ObjectRegion")
local PlayerDataStoreService = require("PlayerDataStoreService")
local PlayerRestaurantShared = require("PlayerRestaurantShared")
local RxBrioUtils = require("RxBrioUtils")
local ServiceBag = require("ServiceBag")

local PlayerRestaurantServer = setmetatable({}, PlayerRestaurantShared)
PlayerRestaurantServer.__index = PlayerRestaurantServer
PlayerRestaurantServer.ServiceName = "PlayerRestaurantServer"

export type PlayerRestaurantServer = typeof(setmetatable(
	{} :: {
		_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
		_gamebeastService: GamebeastService.GamebeastService,

		_equippedFridge: AttributeValue.AttributeValue<string>,
	},
	PlayerRestaurantServer
))

function PlayerRestaurantServer.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self =
		setmetatable(PlayerRestaurantShared.new(instance, serviceBag), PlayerRestaurantServer) :: PlayerRestaurantServer

	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)

	assert(self._player, "Player not found")

	self._equippedFridge = AttributeValue.new(self._instance, "EquippedFridge")

	self._maid:GivePromise(
		self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
			local subStore = dataStore:GetSubStore(self._player.SaveSlot.Value) :: DataStore.DataStore

			self._maid:GivePromise(
				subStore
					:Load("EquippedFridge", self._configService:GetGeneralConfigValue("DefaultFridge"))
					:Then(function(equippedFridgeName: string)
						self._equippedFridge.Value = equippedFridgeName
					end)
			)

			self._maid:GiveTask(subStore:StoreOnValueChange("EquippedFridge", self._equippedFridge))
		end)
	)

	self._maid:GiveTask(self._equippedFridge
		:ObserveBrio()
		:Pipe({
			RxBrioUtils.where(function(equippedFridgeName: string)
				return equippedFridgeName ~= nil
			end),
		})
		:Subscribe(function(brio)
			local maid, equippedFridgeName = brio:ToMaidAndValue()

			local fridgeConfig = self._configService:GetFridge(equippedFridgeName)
			local fridge = FridgeUtils.createFridge(fridgeConfig)
			fridge.Parent = self._instance
			fridge:PivotTo(self._instance.FridgeSlot:GetPivot())

			maid:GiveTask(fridge)
		end))

	local emptyBackpackArea = self._instance.EmptyBackpackArea
	local emptyBackpackAreaRegion = ObjectRegion.new(self._serviceBag, emptyBackpackArea.Region, function(part)
		local parent = part.Parent
		if parent:IsA("Model") and parent:HasTag("ItemBackpack") then
			return parent
		end

		return nil
	end)

	self._maid:GiveTask(emptyBackpackAreaRegion)

	return self
end

function PlayerRestaurantServer.Destroy(self: PlayerRestaurantServer)
	PlayerRestaurantShared.Destroy(self)
end

return Binder.new("PlayerRestaurant", PlayerRestaurantServer)
