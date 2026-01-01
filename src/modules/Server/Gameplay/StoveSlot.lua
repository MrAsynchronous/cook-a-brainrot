local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Blend = require("Blend")
local ConfigService = require("ConfigService")
local Maid = require("Maid")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")
local StoveSlotData = require("StoveSlotData")

local StoveSlot = {}
StoveSlot.__index = StoveSlot
StoveSlot.ServiceName = "StoveSlot"

export type StoveSlot = typeof(StoveSlot) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,
	_instance: Instance,
}

function StoveSlot.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, StoveSlot)

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._instance = assert(instance, "No instance")

	self._configService = serviceBag:GetService(ConfigService)

	self._data = StoveSlotData:Create(instance)

	self._maid:GiveTask(Blend.mount(self._instance, {
		Blend.Find "Part" {
			Name = "PrimaryPart",

			Color = self._data.Locked:Observe():Pipe({
				Rx.map(function(locked: boolean)
					return locked and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
				end),
			}),

			Transparency = self._data.Stove:Observe():Pipe({
				Rx.map(function(stoveName: string)
					return stoveName == "None" and 0 or 1
				end),
			}),
		},
	}))

	self._maid:GiveTask(self._data.Locked:Observe():Subscribe(function(locked: boolean)
		if locked then
			self._maid._lockedText = Blend.mount(self._instance, {
				Blend.New "BillboardGui" {
					Size = UDim2.fromScale(3, 1.25),
					Active = true,
					AlwaysOnTop = true,
					ClipsDescendants = true,
					LightInfluence = 1,
					StudsOffsetWorldSpace = Vector3.new(0, 3, 0),
					Blend.New "TextLabel" {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						FontFace = Font.new(
							"rbxasset://fonts/families/SourceSansPro.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = self._data.PurchasePrice:Observe():Pipe({
							Rx.map(function(purchasePrice: number)
								return string.format("$%d", purchasePrice)
							end),
						}),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextWrapped = true,
					},
				},

				Blend.New "ProximityPrompt" {
					ActionText = self._data.PurchasePrice:Observe():Pipe({
						Rx.map(function(purchasePrice: number)
							return string.format("$%d", purchasePrice)
						end),
					}),
					ObjectText = "Purchase for",
					RequiresLineOfSight = false,
					MaxActivationDistance = 8,
					HoldDuration = 1,
				},
			})
		else
			self._maid._lockedText = nil
		end
	end))

	self._maid:GiveTask(self._data.Stove:Observe():Subscribe(function(stoveName: string)
		if stoveName == "None" then
			self._maid._stove = nil
		else
			local stoveAsset = self._configService:GetStoveAsset(stoveName):Clone()
			stoveAsset.Parent = self._instance
			stoveAsset:PivotTo(self._instance.PrimaryPart:GetPivot())
			self._maid:GiveTask(stoveAsset)
		end
	end))

	return self
end

function StoveSlot.Destroy(self: StoveSlot)
	self._maid:Destroy()
end

return Binder.new("StoveSlot", StoveSlot)
