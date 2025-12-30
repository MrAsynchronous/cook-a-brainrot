local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local DataStore = require("DataStore")
local Maid = require("Maid")
local PlayerDataStoreService = require("PlayerDataStoreService")
local ServiceBag = require("ServiceBag")

local PlayerRestaurant = {}
PlayerRestaurant.__index = PlayerRestaurant
PlayerRestaurant.ServiceName = "PlayerRestaurant"

export type PlayerRestaurant = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,
		_instance: Instance,
		_player: Player,
		_playerName: AttributeValue.AttributeValue<string | nil>,
		_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
	},
	{} :: typeof({ __index = PlayerRestaurant })
))

function PlayerRestaurant.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, PlayerRestaurant)
	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._instance = assert(instance, "No instance")

	self._playerName = AttributeValue.new(self._instance, "PlayerName")
	self._player = Players:FindFirstChild(self._playerName.Value)
	assert(self._player, "Player not found")

	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)

	self._maid:GivePromise(
		self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
			self._dataContainer = Instance.new("Folder")
			self._dataContainer.Name = "PlayerData"
			self._dataContainer.Parent = self._instance

			local subStore = dataStore:GetSubStore(self._player.SaveSlot.Value)

			self._maid:GivePromise(subStore:Load("Pantry", {}):Then(function(pantry: { { [string]: number } })
				local pantryContainer = Instance.new("Folder")
				pantryContainer.Name = "Pantry"
				pantryContainer.Parent = self._instance

				for ingredientName, amount in pantry do
					local ingredient = self._itemService:GetIngredient(ingredientName)
					if ingredient then
						local ingredientObject = ingredient.Value:Clone()
						ingredientObject.Parent = pantryContainer
					end
				end
			end))

			self._maid:GivePromise(subStore:Load("Cash", 20):Then(function(cash: number)
				local cashValue = AttributeValue.new(self._dataContainer, "Cash")
				cashValue.Value = cash
				self._maid:GiveTask(subStore:StoreOnValueChange("Cash", cashValue))
			end))
		end)
	)

	return self
end

function PlayerRestaurant.Destroy(self: PlayerRestaurant)
	self._maid:Destroy()
end

return Binder.new("PlayerRestaurant", PlayerRestaurant)
