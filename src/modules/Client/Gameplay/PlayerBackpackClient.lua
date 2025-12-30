local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Brio = require("Brio")
local ConfigService = require("ConfigService")
local PlayerBackpackShared = require("PlayerBackpackShared")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local ServiceBag = require("ServiceBag")

local PlayerBackpackClient = setmetatable({}, PlayerBackpackShared)
PlayerBackpackClient.__index = PlayerBackpackClient
PlayerBackpackClient.ServiceName = "PlayerBackpackClient"

export type PlayerBackpackClient = typeof(PlayerBackpackClient) & {} & PlayerBackpackShared.PlayerBackpackShared

function PlayerBackpackClient.new(serviceBag: ServiceBag.ServiceBag, player: Player)
	local self =
		setmetatable(PlayerBackpackShared.new(serviceBag, player), PlayerBackpackClient) :: PlayerBackpackClient

	self._equippedBackpack = self._player:WaitForChild("EquippedBackpack")

	self._maid:GiveTask(RxBrioUtils.flatCombineLatestBrio({
		equippedBackpack = self:ObserveEquippedBackpackBrio(),
		backpackAsset = self:ObservePlayerBackpackAssetBrio(),
	}, function(data)
		return data.equippedBackpack ~= nil and data.backpackAsset ~= nil
	end):Subscribe(function(brio: Brio.Brio<{
		equippedBackpack: ConfigService.Backpack,
		backpackAsset: Model,
	}>)
		local maid, data = brio:ToMaidAndValue()
		local equippedBackpack = data.equippedBackpack
		local backpackAsset = data.backpackAsset

		maid:GiveTask(Blend.mount(backpackAsset, {
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
						items = self:ObserveTotalItemCount(),
						capacity = RxInstanceUtils.observeProperty(equippedBackpack.Capacity, "Value"),
					}):Pipe({
						Rx.map(function(state)
							return string.format("%d/%d", state.items, state.capacity)
						end),
					}),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextWrapped = true,
				},
			},
		}))
	end))

	return self
end

function PlayerBackpackClient.Destroy(self: PlayerBackpackClient)
	PlayerBackpackShared.Destroy(self)
end

return PlayerBackpackClient
