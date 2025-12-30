local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ServiceBag = require("ServiceBag")
local Observable = require("Observable")
local Maid = require("Maid")
local Gamebeast = require("Gamebeast")
local Rx = require("Rx")

local GamebeastService = {}
GamebeastService.ServiceName = "GamebeastService"

export type GamebeastService = typeof(GamebeastService) & {
    _serviceBag: ServiceBag.ServiceBag,
    _gamebeast: any,
    _configs: any,
    _markers: any
}

--[[
    Tracks an event.
]]
function GamebeastService.TrackEvent(self: GamebeastService, eventName: string, data: any)
    task.defer(function()
        local markers = Gamebeast:GetService("Markers") :: Gamebeast.MarkersService
        markers:SendMarker(eventName, data)
    end)
end

--[[
    Tracks a user event.
]]
function GamebeastService.TrackUserEvent(self: GamebeastService, player: Player, eventName: string, data: any)
    if (not RunService:IsServer()) then
        return warn("GamebeastService.TrackUserEvent is only available on the server")
    end

    task.defer(function()
        local markers = Gamebeast:GetService("Markers") :: Gamebeast.MarkersService
        markers:SendPlayerMarker(player, eventName, data)
    end)
end

--[[
    Observes the config at the given path. Observes the configs ready state and then observes the config at the given path.
]]
function GamebeastService.ObserveConfig(self: GamebeastService, path: string | {string})
    local configs = Gamebeast:GetService("Configs") :: Gamebeast.ConfigsService
    
    return self:ObserveConfigsReady():Pipe({
        Rx.switchMap(function()
            return Observable.new(function(subscriber)
                local maid = Maid.new()
        
                maid:GiveTask(configs:Observe(path, function(newValue, oldValue)
                    subscriber:Fire(newValue, oldValue)
                end))
        
                return maid
            end)
        end)
    })
end

--[[
    Observes the configs ready state.
]]
function GamebeastService.ObserveConfigsReady(self: GamebeastService)
    local configs = Gamebeast:GetService("Configs") :: Gamebeast.ConfigsService

    return Observable.new(function(subscriber)
        local maid = Maid.new()

        maid:GiveTask(configs:OnReady(function()
            subscriber:Fire()
            subscriber:Complete()
        end))

        return maid
    end)
end

--[[
    Gets the experiment group for the given player.
]]
function GamebeastService.GetExperimentGroupForPlayer(self: GamebeastService, player: Player): { experimentName: string, groupName: string }?
    local experiments = Gamebeast:GetService("Experiments") :: Gamebeast.ExperimentsService

    return experiments:GetGroupForPlayer(player)
end

function GamebeastService:Init(serviceBag: ServiceBag.ServiceBag)
    self._serviceBag = serviceBag
end

function GamebeastService:Start()
    if (RunService:IsServer()) then
        Gamebeast:Setup({
            key = HttpService:GetSecret("GAMEBEAST_TOKEN")
        })
    else
        Gamebeast:Setup()
    end
end

return GamebeastService