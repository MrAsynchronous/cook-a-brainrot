local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameBindersService = {}
GameBindersService.ServiceName = "GameBindersService"

function GameBindersService:Init(serviceBag: ServiceBag.ServiceBag)
    serviceBag:GetService(require("PlayerPlotBinder"))
end

return GameBindersService