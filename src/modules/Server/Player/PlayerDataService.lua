local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local PlayerDataStoreService = require("PlayerDataStoreService")
local RxPlayerUtils = require("RxPlayerUtils")
local ServiceBag = require("ServiceBag")

local PlayerDataService = {}
PlayerDataService.ServiceName = "PlayerDataService"

export type PlayerDataService = typeof(PlayerDataService) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,
	_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
}

function PlayerDataService.Init(self: PlayerDataService, serviceBag: ServiceBag.ServiceBag)
	self._maid = Maid.new()
	self._serviceBag = assert(serviceBag, "No service bag")

	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)
end

function PlayerDataService.Start(self: PlayerDataService)
	self._maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
		local maid, player = brio:ToMaidAndValue()

		maid:GiveTask(Blend.New "StringValue" {
			Name = "SaveSlot",
			Value = "Slot1",
		}:Subscribe(function(stringValue)
			stringValue.Parent = player
		end))
	end))
end

return PlayerDataService
