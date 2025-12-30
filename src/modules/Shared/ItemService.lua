local require = require(script.Parent.loader).load(script)

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServiceBag = require("ServiceBag")

export type Rarity = Configuration & {
    Color: Color3Value
}

export type Ingredient = ObjectValue & {
    Value: Model,
    Rarity: ObjectValue & {
        Value: Rarity
    }
}

export type Brainrot = ObjectValue & {
    Value: Model,
    Rarity: ObjectValue & {
        Value: Rarity
    },
    Recipe: Folder
}

local ItemService = {}
ItemService.ServiceName = "ItemService"

export type ItemService = typeof(ItemService) & {
    _serviceBag: ServiceBag.ServiceBag,

    _configContainer: Configuration & {
        Brainrot: Folder,
        Ingredients: Folder,
        ItemRarities: Folder
    },
    _assetsFolder: Folder & {
        Brainrot: Folder,
        Ingredients: Folder
    },
    _droppedIngredientsFolder: Folder
}

function ItemService.GetItemRarities(self: ItemService): {Rarity}
    return self._configContainer.ItemRarities:GetChildren() :: {Rarity}
end

function ItemService.GetRarity(self: ItemService, rarityName: string): Rarity
    return self._configContainer.ItemRarities:FindFirstChild(rarityName) :: Rarity
end

function ItemService.GetIngredients(self: ItemService): {Ingredient}
    return self._configContainer.Ingredients:GetChildren() :: {Ingredient}
end

function ItemService.GetIngredient(self: ItemService, ingredientName: string): Ingredient?
    return self._configContainer.Ingredients:FindFirstChild(ingredientName) :: Ingredient
end

function ItemService.GetDroppedIngredientsFolder(self: ItemService): Folder
    return self._droppedIngredientsFolder
end

function ItemService.GetGeneralConfig(self: ItemService): Configuration
    return self._configContainer
end

function ItemService.Init(self: ItemService, serviceBag: ServiceBag.ServiceBag)
    self._serviceBag = serviceBag

    if (RunService:IsServer()) then
        self:_initServer()
    else
        self:_initClient()
    end
end

function ItemService._initServer(self: ItemService)
    if (not RunService:IsServer()) then
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

function ItemService._initClient(self: ItemService)
    if (not RunService:IsClient()) then
        return
    end

    self._configContainer = ReplicatedStorage:WaitForChild("GameConfig")
    self._assetsFolder = ReplicatedStorage:WaitForChild("Assets")
    self._droppedIngredientsFolder = Workspace:WaitForChild("Dropped Ingredients")
end

return ItemService