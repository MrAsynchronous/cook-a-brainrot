local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Blend = require("Blend")
local ConfigService = require("ConfigService")
local DataStore = require("DataStore")
local GamebeastService = require("GamebeastService")
local PlayerBackpackServer = require("PlayerBackpackServer")
local PlayerDataStoreService = require("PlayerDataStoreService")
local PlayerRestaurantShared = require("PlayerRestaurantShared")
local ServiceBag = require("ServiceBag")

local PlayerRestaurantServer = setmetatable({}, PlayerRestaurantShared)
PlayerRestaurantServer.__index = PlayerRestaurantServer
PlayerRestaurantServer.ServiceName = "PlayerRestaurantServer"

export type PlayerRestaurantServer = typeof(PlayerRestaurantServer) & {
	_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
	_gamebeastService: GamebeastService.GamebeastService,

	_backpack: PlayerBackpackServer.PlayerBackpackServer,
} & PlayerRestaurantShared.PlayerRestaurantShared

function PlayerRestaurantServer.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self =
		setmetatable(PlayerRestaurantShared.new(instance, serviceBag), PlayerRestaurantServer) :: PlayerRestaurantServer

	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)
	self._gamebeastService = serviceBag:GetService(GamebeastService)

	assert(self._player, "Player not found")

	self._backpack = PlayerBackpackServer.new(serviceBag, self._player)

	-- self._maid:GiveTask(Blend.mount(self._instance, {
	-- 	Blend.New "Folder" {
	-- 		Name = "Pantry",

	-- 		[Blend.Instance] = function(folder: Folder)
	-- 			self._pantry = folder
	-- 		end,
	-- 	},
	-- 	Blend.New "Folder" {
	-- 		Name = "Backpack",

	-- 		[Blend.Instance] = function(folder: Folder)
	-- 			self._backpack = folder
	-- 		end,
	-- 	},
	-- }))

	-- self._maid:GivePromise(
	-- 	self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
	-- 		local subStore = dataStore:GetSubStore(self._player.SaveSlot.Value) :: DataStore.DataStore

	-- 		self._maid:GivePromise(subStore:Load("Pantry", {}):Then(function(pantry: { { [string]: number } })
	-- 			for ingredientName, amount in pantry do
	-- 				local ingredient = self._configService:GetIngredient(ingredientName)
	-- 				if ingredient then
	-- 					self:AddIngredientToPantry(ingredient)
	-- 				end
	-- 			end
	-- 		end))

	-- 		self._maid:GiveTask(subStore:AddSavingCallback(function()
	-- 			local pantry = {}
	-- 			for _, ingredientObject in self._pantry:GetChildren() do
	-- 				if not ingredientObject:IsA("NumberValue") then
	-- 					self._gamebeastService:TrackPlayerEventDebug(self._player, "InvalidPantryIngredientObject", {
	-- 						action = "OnSavePantry",
	-- 						ingredientName = ingredientObject.Name,
	-- 						className = ingredientObject.ClassName,
	-- 					})

	-- 					continue
	-- 				end

	-- 				-- no need to save 0 ingredients
	-- 				if ingredientObject.Value == 0 then
	-- 					continue
	-- 				end

	-- 				pantry[ingredientObject.Name] = ingredientObject.Value
	-- 			end

	-- 			subStore:Store("Pantry", pantry)
	-- 		end))
	-- 	end)
	-- )

	return self
end

function PlayerRestaurantServer.GetBackpack(self: PlayerRestaurantServer): PlayerBackpackServer.PlayerBackpackServer
	return self._backpack
end

-- function PlayerRestaurantServer.AddIngredientToPantry(
-- 	self: PlayerRestaurantServer,
-- 	ingredient: ConfigService.Ingredient
-- )
-- 	local ingredientObject = self:_upsertIngredientObject(self._pantry, ingredient)
-- 	ingredientObject.Value += 1
-- end

function PlayerRestaurantServer.Destroy(self: PlayerRestaurantServer)
	PlayerRestaurantShared.Destroy(self)
end

return Binder.new("PlayerRestaurant", PlayerRestaurantServer)
