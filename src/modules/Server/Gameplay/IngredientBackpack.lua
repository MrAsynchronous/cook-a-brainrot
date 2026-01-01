local require = require(script.Parent.loader).load(script)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local Blend = require("Blend")
local Brio = require("Brio")
local ConfigService = require("ConfigService")
local IngredientBackpackData = require("IngredientBackpackData")
local IngredientData = require("IngredientData")
local Maid = require("Maid")
local ModelUtils = require("ModelUtils")
local R15Utils = require("R15Utils")
local Rx = require("Rx")
local RxChildUtils = require("RxChildUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local ServiceBag = require("ServiceBag")
local WeldConstraintUtils = require("WeldConstraintUtils")

local IngredientBackpack = {}
IngredientBackpack.__index = IngredientBackpack
IngredientBackpack.ServiceName = "IngredientBackpack"

export type IngredientBackpack = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,

		_instance: IngredientBackpackAsset,
		_backpackName: AttributeValue.AttributeValue<string>,
		_collectable: AttributeValue.AttributeValue<boolean>,
		_itemContainer: Folder,
		_owner: ObjectValue,
	},
	IngredientBackpack
))

export type IngredientBackpackAsset = Model & {
	Owner: ObjectValue & {
		Value: Player | Instance,
	},
	Items: Configuration,
}

function IngredientBackpack.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, IngredientBackpack) :: IngredientBackpack

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._instance = assert(instance, "No instance")

	self._configService = serviceBag:GetService(ConfigService)

	self._data = IngredientBackpackData:Create(self._instance)

	self._itemContainer = Instance.new("Configuration")
	self._itemContainer.Name = "Items"
	self._itemContainer.Parent = self._instance
	self._maid:GiveTask(self._itemContainer)

	self._maid:GiveTask(RxInstanceUtils.observeParentBrio(self._instance):Subscribe(function(brio: Brio.Brio<Instance>)
		local maid: Maid.Maid, parent: Instance = brio:ToMaidAndValue()

		local parentHumanoid = parent:FindFirstChildOfClass("Humanoid")
		if parentHumanoid and parentHumanoid.Health > 0 then
			ModelUtils.setModelCanCollide(self._instance, false)
			parentHumanoid.BreakJointsOnDeath = false

			self:_mountBackpack(maid, parent)

			maid:GiveTask(parentHumanoid.Died:Connect(function()
				ModelUtils.setModelCanCollide(self._instance, true)
				self._instance.Parent = Workspace
			end))
		end

		self._data.Owner.Value = if Players:GetPlayerFromCharacter(parent)
			then Players:GetPlayerFromCharacter(parent).Name
			else parent.Name
	end))

	self._maid:GiveTask(Blend.mount(self._instance, {
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
					items = RxChildUtils.observeChildCount(self._itemContainer),
					capacity = self._data.Capacity:Observe(),
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

	return self
end

function IngredientBackpack.AddItem(self: IngredientBackpack, item: Instance): boolean
	if self:IsFull() then
		return false
	end

	local ingredientData = IngredientData:Get(item)

	local backpackItem = Instance.new("Folder")
	backpackItem.Name = ingredientData.Name
	backpackItem.Parent = self._itemContainer

	IngredientData:Set(backpackItem, ingredientData)

	return true
end

function IngredientBackpack.IsFull(self: IngredientBackpack): boolean
	return #self._itemContainer:GetChildren() >= self._data.Capacity.Value
end

function IngredientBackpack.GiveToEntity(self: IngredientBackpack, entity: Instance)
	self._instance.Parent = entity
end

function IngredientBackpack._mountBackpack(self: IngredientBackpack, maid: Maid.Maid, parent: Instance)
	local torso = R15Utils.getBodyPart(parent, "UpperTorso") or R15Utils.getBodyPart(parent, "Torso")

	self._instance:PivotTo(torso:GetPivot())

	maid:GiveTask(
		WeldConstraintUtils.namedBetween("BackpackWeld", self._instance.PrimaryPart, torso, self._instance.PrimaryPart)
	)
end

function IngredientBackpack.Destroy(self: IngredientBackpack)
	self._maid:Destroy()
end

return Binder.new("IngredientBackpack", IngredientBackpack)
