local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local FridgeData = require("FridgeData")
local GameConfigData = require("GameConfigData")
local IngredientBackpackConfigData = require("IngredientBackpackConfigData")
local IngredientData = require("IngredientData")
local RarityConfigData = require("RarityConfigData")
local ServiceBag = require("ServiceBag")
local StoveConfigData = require("StoveConfigData")
local StoveSlotConfigData = require("StoveSlotConfigData")

local ConfigService = {}
ConfigService.ServiceName = "ConfigService"

export type ConfigService = typeof(ConfigService) & {
	_serviceBag: ServiceBag.ServiceBag,

	_configContainer: Configuration & {
		Brainrot: Folder,
		Ingredients: Folder,
		ItemRarities: Folder,
		Backpacks: Folder,
		Fridges: Folder,
		Stoves: Folder,
		StoveSlots: Folder,
	},
	_assetsFolder: Folder & {
		Brainrot: Folder,
		Ingredients: Folder,
		Backpacks: Folder,
		Fridges: Folder,
		Stoves: Folder,
	},
}

function ConfigService.GetStoveSlotConfig(self: ConfigService, slotId: string)
	local slotObject = self._configContainer.StoveSlots:FindFirstChild(slotId)
	if not slotObject then
		return nil
	end

	return StoveSlotConfigData:Create(slotObject)
end

function ConfigService.GetRarityConfig(self: ConfigService, rarityName: string)
	local rarityObject = self:_findObject(self._configContainer.ItemRarities, rarityName)
	if not rarityObject then
		return nil
	end

	return RarityConfigData:Create(rarityObject)
end

function ConfigService.GetIngredientConfig(self: ConfigService, ingredientName: string)
	local ingredientObject = self:_findObject(self._configContainer.Ingredients, ingredientName)
	if not ingredientObject then
		return nil
	end

	return IngredientData:Create(ingredientObject)
end

function ConfigService.GetBackpackConfig(self: ConfigService, backpackName: string)
	local backpackObject = self:_findObject(self._configContainer.Backpacks, backpackName)
	if not backpackObject then
		return nil
	end

	return IngredientBackpackConfigData:Create(backpackObject)
end

function ConfigService.GetFridgeConfig(self: ConfigService, fridgeName: string)
	local fridgeObject = self._configContainer.Fridges:FindFirstChild(fridgeName)
	if not fridgeObject then
		return nil
	end

	return FridgeData:Create(fridgeObject)
end

function ConfigService.GetStoveConfig(self: ConfigService, stoveName: string)
	local stoveObject = self._configContainer.Stoves:FindFirstChild(stoveName)
	if not stoveObject then
		return nil
	end

	return StoveConfigData:Create(stoveObject)
end

function ConfigService.GetGameConfig(self: ConfigService)
	return GameConfigData:Create(self._configContainer)
end

function ConfigService.GetIngredientAsset(self: ConfigService, ingredientName: string): Model
	return self._assetsFolder.Ingredients:FindFirstChild(ingredientName) :: Model
end

function ConfigService.GetBackpackAsset(self: ConfigService, backpackName: string): Model
	return self._assetsFolder.Backpacks:FindFirstChild(backpackName) :: Model
end

function ConfigService.GetFridgeAsset(self: ConfigService, fridgeName: string): Model
	return self._assetsFolder.Fridges:FindFirstChild(fridgeName) :: Model
end

function ConfigService.GetStoveAsset(self: ConfigService, stoveName: string): Model
	return self._assetsFolder.Stoves:FindFirstChild(stoveName) :: Model
end

function ConfigService.GetConfigContainer(self: ConfigService)
	return self._configContainer
end

function ConfigService._findObject(self: ConfigService, folder: Folder, name: string)
	local object = folder:FindFirstChild(name)
	if not object then
		warn(string.format("Object not found for %s", name))

		return nil
	end

	return object
end

function ConfigService.Init(self: ConfigService, serviceBag: ServiceBag.ServiceBag)
	self._serviceBag = serviceBag

	if RunService:IsServer() then
		self:_initServer()
	else
		self:_initClient()
	end
end

function ConfigService._initServer(self: ConfigService)
	if not RunService:IsServer() then
		return
	end

	-- move assets folder to replicated storage
	local gameFolder = Workspace:WaitForChild("Game")
	self._assetsFolder = gameFolder:WaitForChild("Assets")
	self._assetsFolder.Parent = ReplicatedStorage

	self._configContainer = ReplicatedStorage:WaitForChild("GameConfig")
end

function ConfigService._initClient(self: ConfigService)
	if not RunService:IsClient() then
		return
	end

	self._configContainer = ReplicatedStorage:WaitForChild("GameConfig")

	self._assetsFolder = ReplicatedStorage:WaitForChild("Assets")
end

return ConfigService
