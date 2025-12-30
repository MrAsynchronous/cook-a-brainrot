local require = require(script.Parent.loader).load(script)

local ConfigService = require("ConfigService")
local Maid = require("Maid")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxCharacterUtils = require("RxCharacterUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local RxValueBaseUtils = require("RxValueBaseUtils")
local ServiceBag = require("ServiceBag")

local PlayerBackpackShared = {}
PlayerBackpackShared.__index = PlayerBackpackShared
PlayerBackpackShared.ServiceName = "PlayerBackpackShared"

export type PlayerBackpackShared = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,

		_player: Player,
		_equippedBackpack: ObjectValue & { Value: ConfigService.Backpack },
	},
	PlayerBackpackShared
))

function PlayerBackpackShared.new(serviceBag: ServiceBag.ServiceBag, player: Player)
	local self = setmetatable({}, PlayerBackpackShared) :: PlayerBackpackShared

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)

	self._player = assert(player, "No player")

	return self
end

function PlayerBackpackShared.IsFull(self: PlayerBackpackShared): boolean
	return self:GetTotalItemCount() >= self:GetEquippedBackpack().Capacity.Value
end

function PlayerBackpackShared.ObserveTotalItemCountBrio(self: PlayerBackpackShared)
	return RxInstanceUtils.observeChildrenBrio(self._equippedBackpack, function(child)
		return child:IsA("NumberValue")
	end):Pipe({
		RxBrioUtils.reduceToAliveList(),
		RxBrioUtils.switchMapBrio(function(numberValues: { NumberValue })
			local observables = {}
			for _, numberValue in numberValues do
				observables[numberValue.Name] = RxValueBaseUtils.observeValue(numberValue)
			end

			return RxBrioUtils.flatCombineLatest(observables):Pipe({
				Rx.map(function(state: { [string]: number })
					local sum = 0
					for _, value in state do
						if typeof(value) == "number" then
							sum += value
						end
					end
					return sum
				end),
			})
		end),
	})
end

function PlayerBackpackShared.ObserveTotalItemCount(self: PlayerBackpackShared)
	return self:ObserveTotalItemCountBrio():Pipe({
		RxBrioUtils.emitOnDeath(0),
		Rx.startWith({ 0 }),
		Rx.distinct(),
	})
end

function PlayerBackpackShared.GetTotalItemCount(self: PlayerBackpackShared): number
	local count = 0
	for _, child in self._equippedBackpack:GetChildren() do
		if not child:IsA("NumberValue") then
			continue
		end

		count += child.Value
	end

	return count
end

function PlayerBackpackShared.ObserveEquippedBackpackBrio(self: PlayerBackpackShared)
	return RxInstanceUtils.observeLastNamedChildBrio(self._player, "ObjectValue", "EquippedBackpack")
		:Pipe({
			RxBrioUtils.switchMapBrio(function(equippedBackpack: ObjectValue & { Value: ConfigService.Backpack })
				return RxInstanceUtils.observePropertyBrio(equippedBackpack, "Value")
			end),
		})
		:Pipe({
			RxBrioUtils.where(function(equippedBackpack: ConfigService.Backpack)
				return equippedBackpack ~= nil
			end),
		})
end

function PlayerBackpackShared.ObservePlayerBackpackAssetBrio(self: PlayerBackpackShared)
	return RxBrioUtils.flatCombineLatestBrio({
		equippedBackpack = self:ObserveEquippedBackpackBrio(),
		character = RxCharacterUtils.observeCharacterBrio(self._player),
	}, function(data)
		return data.character ~= nil and data.equippedBackpack ~= nil
	end):Pipe({
		RxBrioUtils.switchMapBrio(function(data: {
			equippedBackpack: ConfigService.Backpack,
			character: Model,
		})
			return RxInstanceUtils.observeLastNamedChildBrio(data.character, "Model", data.equippedBackpack.Value.Name)
		end),

		RxBrioUtils.where(function(backpackAsset: Model)
			return backpackAsset ~= nil
		end),
	})
end

function PlayerBackpackShared.GetEquippedBackpack(self: PlayerBackpackShared): ConfigService.Backpack
	return self._equippedBackpack.Value
end

function PlayerBackpackShared.Destroy(self: PlayerBackpackShared)
	self._maid:Destroy()
end

return PlayerBackpackShared
