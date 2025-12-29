local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServiceBag = require("ServiceBag")

local GamebeastServiceClient = {}
GamebeastServiceClient.ServiceName = "GamebeastServiceClient"

function GamebeastServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
    self._serviceBag = serviceBag
    self._gamebeast = require(ReplicatedStorage:WaitForChild("Gamebeast"))
end

function GamebeastServiceClient:Start()
    self._gamebeast:Setup()
end

return GamebeastServiceClient