local require = require(script.Parent.loader).load(script)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local Blend = require("Blend")
local ConfigService = require("ConfigService")
local DataStore = require("DataStore")
local FridgeData = require("FridgeData")
local GamebeastService = require("GamebeastService")
local IngredientBackpack = require("IngredientBackpack")
local IngredientBackpackData = require("IngredientBackpackData")
local Maid = require("Maid")
local ObjectRegion = require("ObjectRegion")
local PlayerDataStoreService = require("PlayerDataStoreService")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxChildUtils = require("RxChildUtils")
local ServiceBag = require("ServiceBag")
local StoveSlotConfigData = require("StoveSlotConfigData")
local StoveSlotData = require("StoveSlotData")

local PlayerRestaurant = {}
PlayerRestaurant.__index = PlayerRestaurant
PlayerRestaurant.ServiceName = "PlayerRestaurant"

export type PlayerRestaurant = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,
		_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
		_gamebeastService: GamebeastService.GamebeastService,

		_instance: Instance,
		_player: Player,
		_playerName: AttributeValue.AttributeValue<string>,
		_equippedFridge: AttributeValue.AttributeValue<string>,
		_emptyBackpackRegion: ObjectRegion.ObjectRegion,
		_fridgeContents: Instance,
	},
	PlayerRestaurant
))

function PlayerRestaurant.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, PlayerRestaurant) :: PlayerRestaurant
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)
	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)

	self._instance = assert(instance, "No instance")
	self._fridgeSlot = self._instance:FindFirstChild("FridgeSlot")
	self._stoveSlots = self._instance:FindFirstChild("StoveSlots")

	self._playerName = AttributeValue.new(self._instance, "PlayerName")
	self._player = assert(Players:FindFirstChild(self._playerName.Value), "Player not found")
	self._equippedFridge = AttributeValue.new(self._instance, "EquippedFridge")

	self._fridgeContents = Instance.new("Folder")
	self._fridgeContents.Name = "FridgeContents"
	self._fridgeContents.Parent = self._instance
	self._maid:GiveTask(self._fridgeContents)

	self._maid:GiveTask(self._equippedFridge
		:ObserveBrio()
		:Pipe({
			RxBrioUtils.where(function(equippedFridge: string)
				return equippedFridge ~= nil
			end),
		})
		:Subscribe(function(brio)
			local maid, equippedFridge = brio:ToMaidAndValue()

			local fridgeConfig = self._configService:GetFridgeConfig(equippedFridge)
			local fridgeAsset = self._configService:GetFridgeAsset(equippedFridge):Clone()
			FridgeData:Set(fridgeAsset, fridgeConfig.Value)

			fridgeAsset.Parent = self._instance
			maid:GiveTask(fridgeAsset)

			fridgeAsset:PivotTo(self._fridgeSlot:GetPivot())

			maid:GiveTask(Blend.mount(fridgeAsset, {
				Blend.New "BillboardGui" {
					Size = UDim2.fromScale(3, 1.25),
					Active = true,
					AlwaysOnTop = true,
					ClipsDescendants = true,
					LightInfluence = 1,
					Blend.New "TextLabel" {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						FontFace = Font.new(
							"rbxasset://fonts/families/SourceSansPro.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = Rx.combineLatest({
							items = RxChildUtils.observeChildCount(self._fridgeContents),
							capacity = fridgeConfig.Capacity:Observe(),
						}):Pipe({
							Rx.map(function(data)
								return string.format("%d/%d", data.items, data.capacity)
							end),
						}),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextWrapped = true,
					},
				},
			}))
		end))

	self._emptyBackpackRegion = ObjectRegion.new(
		self._serviceBag,
		self._instance.EmptyBackpackArea.Region,
		function(part)
			local parent = part.Parent
			if parent:IsA("Model") and parent:HasTag("IngredientBackpack") then
				return parent
			end

			return nil
		end
	)

	self._maid:GiveTask(self._emptyBackpackRegion)

	self._maid:GiveTask(self._emptyBackpackRegion:ObserveObjectsInRegionBrio():Subscribe(function(brio)
		local _maid, object: IngredientBackpack.IngredientBackpackAsset = brio:ToMaidAndValue()

		local data = IngredientBackpackData:Create(object)

		if data.Owner.Value == self._player.Name then
			local itemsContainer = object:FindFirstChild("Items") :: Configuration?
			if not itemsContainer then
				warn("No item container found on backpack")
				return
			end

			for _, item in itemsContainer:GetChildren() do
				item.Parent = self._fridgeContents
			end
		else
			print("TODO: handle NPCs")
		end
	end))

	self:_loadFridge()
	self:_loadStoveSlots()

	return self
end

function PlayerRestaurant.AddIngredientToFridge(self: PlayerRestaurant, ingredient: Instance)
	ingredient.Parent = self._fridgeContents
end

function PlayerRestaurant._loadFridge(self: PlayerRestaurant)
	self._maid:GivePromise(
		self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
			local saveSlot = self._player:FindFirstChild("SaveSlot") :: StringValue
			local subStore = dataStore:GetSubStore(saveSlot.Value) :: DataStore.DataStore

			local defaultFridge = self._configService:GetGameConfig().DefaultFridge.Value

			self._maid:GivePromise(
				subStore:Load("EquippedFridge", defaultFridge):Then(function(equippedFridgeName: string)
					self._equippedFridge.Value = equippedFridgeName
				end)
			)

			self._maid:GiveTask(subStore:StoreOnValueChange("EquippedFridge", self._equippedFridge))
		end)
	)
end

function PlayerRestaurant._loadStoveSlots(self: PlayerRestaurant)
	self._maid:GivePromise(
		self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
			local saveSlot = self._player:FindFirstChild("SaveSlot") :: StringValue
			local subStore = dataStore:GetSubStore(saveSlot.Value) :: DataStore.DataStore

			self._maid:GivePromise(
				subStore:Load("StoveSlots", {}):Then(function(stoves: { [string]: { Stove: string, Brainrot: string } })
					for _, stoveSlot in self._stoveSlots:GetChildren() do
						-- apply config data
						local slotConfig = self._configService:GetStoveSlotConfig(stoveSlot.Name)
						StoveSlotConfigData:Set(stoveSlot, slotConfig.Value)

						-- create data object for use
						local slotData = StoveSlotData:Create(stoveSlot)

						slotData.Owner.Value = self._player.Name

						-- apply saved data
						local savedSlotData = stoves[slotData.Name.Value]
						if savedSlotData then
							slotData.Stove.Value = savedSlotData.Stove
						end
					end
				end)
			)

			self._maid:GiveTask(subStore:StoreOnValueChange("EquippedFridge", self._equippedFridge))
		end)
	)
end

function PlayerRestaurant.Destroy(self: PlayerRestaurant)
	self._maid:Destroy()
end

return Binder.new("PlayerRestaurant", PlayerRestaurant)
