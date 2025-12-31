local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Observable = require("Observable")
local RxAttributeUtils = require("RxAttributeUtils")
local ServiceBag = require("ServiceBag")

export type Rarity = Configuration & {
	Color: Color3Value,
}

export type Ingredient = ObjectValue & {
	Value: Model,
	Rarity: ObjectValue & {
		Value: Rarity,
	},
	Type: StringValue & {
		Value: "Ingredient",
	},
}

export type Brainrot = ObjectValue & {
	Value: Model,
	Rarity: ObjectValue & {
		Value: Rarity,
	},
	Type: StringValue & {
		Value: "Brainrot",
	},
	Recipe: Folder,
}

export type Backpack = ObjectValue & {
	Value: Model,
	Capacity: NumberValue,
	Type: StringValue & {
		Value: "Backpack",
	},
}

export type Fridge = ObjectValue & {
	Value: Model,
	Type: StringValue & {
		Value: "Fridge",
	},
	Capacity: NumberValue,
}

export type Item = Ingredient | Brainrot | Backpack

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
	},
	_assetsFolder: Folder & {
		Brainrot: Folder,
		Ingredients: Folder,
		Backpacks: Folder,
		Fridges: Folder,
	},
	_droppedIngredientsFolder: Folder,
}

function ConfigService.GetItemRarities(self: ConfigService): { Rarity }
	return self._configContainer.ItemRarities:GetChildren() :: { Rarity }
end

function ConfigService.GetRarity(self: ConfigService, rarityName: string): Rarity
	return self._configContainer.ItemRarities:FindFirstChild(rarityName) :: Rarity
end

function ConfigService.GetIngredients(self: ConfigService): { Ingredient }
	return self._configContainer.Ingredients:GetChildren() :: { Ingredient }
end

function ConfigService.GetIngredient(self: ConfigService, ingredientName: string): Ingredient?
	return self._configContainer.Ingredients:FindFirstChild(ingredientName) :: Ingredient
end

function ConfigService.GetBackpacks(self: ConfigService): { Backpack }
	return self._configContainer.Backpacks:GetChildren() :: { Backpack }
end

function ConfigService.GetBackpack(self: ConfigService, backpackName: string): Backpack
	return self._configContainer.Backpacks:FindFirstChild(backpackName) :: Backpack
end

function ConfigService.GetFridges(self: ConfigService): { Fridge }
	return self._configContainer.Fridges:GetChildren() :: { Fridge }
end

function ConfigService.GetFridge(self: ConfigService, fridgeName: string): Fridge
	return self._configContainer.Fridges:FindFirstChild(fridgeName) :: Fridge
end

function ConfigService.GetDroppedIngredientsFolder(self: ConfigService): Folder
	return self._droppedIngredientsFolder
end

function ConfigService.GetGeneralConfigValue<T>(self: ConfigService, config: string): T?
	return self._configContainer:GetAttribute(config) :: T?
end

function ConfigService.ObserveGeneralConfig<T>(self: ConfigService, config: string): Observable.Observable<T?>
	local generalConfig = self._configContainer
	return RxAttributeUtils.observeAttribute(generalConfig, config)
end

function ConfigService.GetConfigContainer(self: ConfigService): Configuration
	return self._configContainer
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

	-- create container folders
	self._droppedIngredientsFolder = Instance.new("Folder")
	self._droppedIngredientsFolder.Parent = Workspace
	self._droppedIngredientsFolder.Name = "Dropped Ingredients"
end

function ConfigService._initClient(self: ConfigService)
	if not RunService:IsClient() then
		return
	end

	self._configContainer = ReplicatedStorage:WaitForChild("GameConfig")
	self._assetsFolder = ReplicatedStorage:WaitForChild("Assets")
	self._droppedIngredientsFolder = Workspace:WaitForChild("Dropped Ingredients")
end

return ConfigService
