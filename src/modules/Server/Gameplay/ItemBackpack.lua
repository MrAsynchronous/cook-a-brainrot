local require = require(script.Parent.loader).load(script)

local Workspace = game:GetService("Workspace")

local AttributeValue = require("AttributeValue")
local BackpackUtils = require("BackpackUtils")
local Binder = require("Binder")
local Blend = require("Blend")
local Brio = require("Brio")
local ConfigService = require("ConfigService")
local Maid = require("Maid")
local ModelUtils = require("ModelUtils")
local R15Utils = require("R15Utils")
local Rx = require("Rx")
local RxInstanceUtils = require("RxInstanceUtils")
local ServiceBag = require("ServiceBag")
local WeldConstraintUtils = require("WeldConstraintUtils")

local ItemBackpack = {}
ItemBackpack.__index = ItemBackpack
ItemBackpack.ServiceName = "ItemBackpack"

export type ItemBackpack = typeof(setmetatable(
	{} :: {
		_serviceBag: ServiceBag.ServiceBag,
		_maid: Maid.Maid,

		_configService: ConfigService.ConfigService,

		_instance: Model,
		_backpackName: AttributeValue.AttributeValue<string>,
		_backpackConfig: ConfigService.Backpack,
		_collectable: AttributeValue.AttributeValue<boolean>,
		_itemContainer: Folder,
		_contentType: AttributeValue.AttributeValue<string>,
	},
	ItemBackpack
))

function ItemBackpack.new(instance: Instance, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable({}, ItemBackpack) :: ItemBackpack

	self._serviceBag = assert(serviceBag, "No service bag")
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)

	self._instance = assert(instance, "No instance")

	self._backpackName = AttributeValue.new(self._instance, "BackpackName")
	self._backpackConfig = self._configService:GetBackpack(self._backpackName.Value)

	self._collectable = AttributeValue.new(self._instance, "Collectable", false)
	self._contentType = AttributeValue.new(self._instance, "ContentType")

	self._itemContainer = Instance.new("Folder")
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
	end))

	self._maid:GiveTask(self._collectable:ObserveBrio():Subscribe(function(brio: Brio.Brio<boolean>)
		local maid: Maid.Maid, collectable: boolean = brio:ToMaidAndValue()

		if collectable then
			maid:GiveTask(Blend.mount(self._instance, {
				Blend.New "ProximityPrompt" {
					ActionText = "Pickup",
					ObjectText = "Backpack",
					RequiresLineOfSight = false,
					Enabled = true,

					[Blend.OnEvent "Triggered"] = function(player: Player)
						self:GiveToEntity(player.Character)
					end,
				},
			}))
		end
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
					items = BackpackUtils.observeContentCount(self._instance),
					capacity = RxInstanceUtils.observeProperty(self._backpackConfig.Capacity, "Value"),
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

function ItemBackpack.AddItem(self: ItemBackpack, item: ConfigService.Item): boolean
	if self:IsFull() then
		return false
	end

	local backpackContentType = self._contentType.Value
	if backpackContentType ~= nil and backpackContentType ~= item.Type.Value then
		return false
	end

	local itemObject = self:_upsertItemObject(item.Name)
	itemObject.Value += 1

	return true
end

function ItemBackpack.IsFull(self: ItemBackpack): boolean
	return BackpackUtils.getContentCount(self._instance) >= self._backpackConfig.Capacity.Value
end

function ItemBackpack.GiveToEntity(self: ItemBackpack, entity: Instance)
	self._instance.Parent = entity
end

function ItemBackpack._upsertItemObject(self: ItemBackpack, itemName: string): NumberValue
	local existingItemObject = self._itemContainer:FindFirstChild(itemName) :: NumberValue?
	if existingItemObject then
		return existingItemObject
	end

	local newItemObject = Instance.new("NumberValue")
	newItemObject.Name = itemName
	newItemObject.Parent = self._itemContainer

	return newItemObject
end

function ItemBackpack._mountBackpack(self: ItemBackpack, maid: Maid.Maid, parent: Instance)
	local torso = R15Utils.getBodyPart(parent, "UpperTorso") or R15Utils.getBodyPart(parent, "Torso")

	self._instance:PivotTo(torso:GetPivot())

	maid:GiveTask(
		WeldConstraintUtils.namedBetween("BackpackWeld", self._instance.PrimaryPart, torso, self._instance.PrimaryPart)
	)
end

function ItemBackpack.Destroy(self: ItemBackpack)
	self._maid:Destroy()
end

return Binder.new("ItemBackpack", ItemBackpack)
