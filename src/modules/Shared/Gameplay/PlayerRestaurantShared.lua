local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")

local AttributeValue = require("AttributeValue")
local ConfigService = require("ConfigService")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local PlayerRestaurantShared = {}
PlayerRestaurantShared.__index = PlayerRestaurantShared
PlayerRestaurantShared.ServiceName = "PlayerRestaurantShared"

export type PlayerRestaurantShared = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,

		_instance: Instance,
		_player: Player,
		_playerName: AttributeValue.AttributeValue<string | nil>,
		_backpack: Folder,
		_pantry: Folder,
		_equippedBackpack: ConfigService.Backpack,
	},
	PlayerRestaurantShared
))

function PlayerRestaurantShared.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, PlayerRestaurantShared) :: PlayerRestaurantShared

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)

	self._instance = assert(instance, "No instance")
	self._playerName = AttributeValue.new(self._instance, "PlayerName")
	self._player = Players:FindFirstChild(self._playerName.Value)

	return self
end

function PlayerRestaurantShared.Destroy(self: PlayerRestaurantShared)
	self._maid:Destroy()
end

return PlayerRestaurantShared
