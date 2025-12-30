local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local PlayerBackpackClient = require("PlayerBackpackClient")
local PlayerRestaurantShared = require("PlayerRestaurantShared")
local ServiceBag = require("ServiceBag")

local PlayerRestaurantClient = setmetatable({}, PlayerRestaurantShared)
PlayerRestaurantClient.__index = PlayerRestaurantClient
PlayerRestaurantClient.ServiceName = "PlayerRestaurantClient"

export type PlayerRestaurantClient = typeof(PlayerRestaurantClient) & {
	_backpack: PlayerBackpackClient.PlayerBackpackClient,
} & PlayerRestaurantShared.PlayerRestaurantShared

function PlayerRestaurantClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self =
		setmetatable(PlayerRestaurantShared.new(instance, serviceBag), PlayerRestaurantClient) :: PlayerRestaurantShared.PlayerRestaurantShared

	self._backpack = PlayerBackpackClient.new(serviceBag, self._player)

	return self
end

function PlayerRestaurantClient.Destroy(self: PlayerRestaurantClient)
	PlayerRestaurantShared.Destroy(self)
end

return Binder.new("PlayerRestaurant", PlayerRestaurantClient)
