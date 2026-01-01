--[=[
	@class GameService
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameService = {}
GameService.ServiceName = "GameService"

function GameService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))
	self._serviceBag:GetService(require("PlotService"))
	self._serviceBag:GetService(require("GamebeastService"))

	-- Internal
	self._serviceBag:GetService(require("ConfigService"))
	self._serviceBag:GetService(require("PlayerDataService"))
	self._serviceBag:GetService(require("GamebeastSyncService"))

	-- Binders
	self._serviceBag:GetService(require("PlayerRestaurant"))
	self._serviceBag:GetService(require("BackpackService"))
	self._serviceBag:GetService(require("IngredientBackpack"))
	self._serviceBag:GetService(require("ShopItem"))
	self._serviceBag:GetService(require("IngredientSpawner"))
	self._serviceBag:GetService(require("DroppedIngredient"))
	self._serviceBag:GetService(require("StoveSlot"))
end

return GameService
