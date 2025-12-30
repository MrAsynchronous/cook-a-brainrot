local require = require(script.Parent.loader).load(script)

local Brio = require("Brio")
local ConfigService = require("ConfigService")
local DataStore = require("DataStore")
local PlayerBackpackShared = require("PlayerBackpackShared")
local PlayerDataStoreService = require("PlayerDataStoreService")
local R15Utils = require("R15Utils")
local RxBrioUtils = require("RxBrioUtils")
local RxCharacterUtils = require("RxCharacterUtils")
local ServiceBag = require("ServiceBag")
local WeldConstraintUtils = require("WeldConstraintUtils")

local PlayerBackpackServer = setmetatable({}, PlayerBackpackShared)
PlayerBackpackServer.__index = PlayerBackpackServer
PlayerBackpackServer.ServiceName = "PlayerBackpackServer"

export type PlayerBackpackServer = typeof(PlayerBackpackServer) & {
	_playerDataStoreService: PlayerDataStoreService.PlayerDataStoreService,
} & PlayerBackpackShared.PlayerBackpackShared

function PlayerBackpackServer.new(serviceBag: ServiceBag.ServiceBag, player: Player)
	local self =
		setmetatable(PlayerBackpackShared.new(serviceBag, player), PlayerBackpackServer) :: PlayerBackpackServer

	self._playerDataStoreService = serviceBag:GetService(PlayerDataStoreService)

	self._equippedBackpack = Instance.new("ObjectValue")
	self._equippedBackpack.Name = "EquippedBackpack"
	self._equippedBackpack.Parent = player
	self._maid:GiveTask(self._equippedBackpack)

	self._maid:GivePromise(
		self._playerDataStoreService:PromiseDataStore(self._player):Then(function(dataStore: DataStore.DataStore)
			local subStore = dataStore:GetSubStore(self._player.SaveSlot.Value) :: DataStore.DataStore

			self._maid:GivePromise(
				subStore
					:Load("EquippedBackpack", self._configService:GetGeneralConfigValue("DefaultBackpack"))
					:Then(function(equippedBackpack: string)
						local backpack = self._configService:GetBackpack(equippedBackpack)
						if not backpack then
							backpack = self._configService:GetBackpack(
								self._configService:GetGeneralConfigValue("DefaultBackpack")
							)
						end

						self._equippedBackpack.Value = backpack
					end)
			)

			self._maid:GiveTask(subStore:AddSavingCallback(function()
				subStore:Store("EquippedBackpack", self._equippedBackpack.Value.Name)
			end))
		end)
	)
	self._maid:GiveTask(RxBrioUtils.flatCombineLatestBrio({
		character = RxCharacterUtils.observeCharacterBrio(self._player),
		equippedBackpack = self:ObserveEquippedBackpackBrio(),
	}, function(data)
		return data.character ~= nil and data.equippedBackpack ~= nil
	end):Subscribe(function(brio: Brio.Brio<{
		character: Model,
		equippedBackpack: ConfigService.Backpack,
	}>)
		local maid, data = brio:ToMaidAndValue()
		local character = data.character
		local equippedBackpack = data.equippedBackpack

		local torso = R15Utils.getBodyPart(character, "UpperTorso") or R15Utils.getBodyPart(character, "Torso")

		local backpackAsset = equippedBackpack.Value:Clone()
		backpackAsset.Parent = character
		backpackAsset:PivotTo(torso:GetPivot())

		maid:GiveTask(WeldConstraintUtils.namedBetween("BackpackWeld", backpackAsset.PrimaryPart, torso, torso))
	end))

	return self
end

function PlayerBackpackServer.AddIngredient(self: PlayerBackpackServer, ingredient: ConfigService.Ingredient): boolean
	if self:IsFull() then
		return false
	end

	local ingredientObject = self:_upsertIngredientObject(ingredient)
	ingredientObject.Value += 1

	return true
end

function PlayerBackpackServer._upsertIngredientObject(
	self: PlayerBackpackServer,
	ingredient: ConfigService.Ingredient
): NumberValue
	local ingredientObject = self._equippedBackpack:FindFirstChild(ingredient.Name) :: NumberValue?
	if ingredientObject then
		return ingredientObject
	end

	local newIngredientObject = Instance.new("NumberValue")
	newIngredientObject.Name = ingredient.Name
	newIngredientObject.Value = 0
	newIngredientObject.Parent = self._equippedBackpack

	return newIngredientObject
end

function PlayerBackpackServer.Destroy(self: PlayerBackpackServer)
	PlayerBackpackShared.Destroy(self)
end

return PlayerBackpackServer
