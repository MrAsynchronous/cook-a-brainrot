local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ServiceBag = require("ServiceBag")

local GamebeastService = {}
GamebeastService.ServiceName = "GamebeastService"

function GamebeastService:Init(serviceBag: ServiceBag.ServiceBag)
    self._serviceBag = serviceBag
    self._gamebeast = require(ReplicatedStorage:WaitForChild("Gamebeast"))
end

function GamebeastService:Start()
    self._gamebeast:Setup({
        key = HttpService:GetSecret("GAMEBEAST_TOKEN")
    })
end

return GamebeastService