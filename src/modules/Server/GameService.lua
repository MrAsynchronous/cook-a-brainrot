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
	self._serviceBag:GetService(require("GameBindersService")) 
end

return GameService