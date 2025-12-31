local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local PlayerRestaurantShared = require("PlayerRestaurantShared")
local ServiceBag = require("ServiceBag")

local PlayerRestaurantClient = setmetatable({}, PlayerRestaurantShared)
PlayerRestaurantClient.__index = PlayerRestaurantClient
PlayerRestaurantClient.ServiceName = "PlayerRestaurantClient"

export type PlayerRestaurantClient = typeof(PlayerRestaurantClient) & {} & PlayerRestaurantShared.PlayerRestaurantShared

function PlayerRestaurantClient.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self =
		setmetatable(PlayerRestaurantShared.new(instance, serviceBag), PlayerRestaurantClient) :: PlayerRestaurantShared.PlayerRestaurantShared

	return self
end

function PlayerRestaurantClient.Destroy(self: PlayerRestaurantClient)
	PlayerRestaurantShared.Destroy(self)
end

return Binder.new("PlayerRestaurant", PlayerRestaurantClient)
