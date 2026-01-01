local require = require(script.Parent.loader).load(script)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ConfigService = require("ConfigService")
local Gamebeast = require("Gamebeast")
local Maid = require("Maid")
local Observable = require("Observable")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")

local GamebeastService = {}
GamebeastService.ServiceName = "GamebeastService"

export type GamebeastService = typeof(GamebeastService) & {
	_serviceBag: ServiceBag.ServiceBag,
	_maid: Maid.Maid,
	_configService: ConfigService.ConfigService,
}

--[[
    Tracks an event.
]]
function GamebeastService.TrackEvent(self: GamebeastService, eventName: string, data: any): thread?
	if not RunService:IsServer() then
		return error("GamebeastService.TrackEvent is only available on the server")
	end

	return task.defer(function()
		local markers = Gamebeast:GetService("Markers") :: Gamebeast.MarkersService
		markers:SendMarker(eventName, data)
	end)
end

--[[
    Tracks a debug event. Won't fire if debug is not enabled.
]]
function GamebeastService.TrackEventDebug(self: GamebeastService, eventName: string, data: any): thread?
	if not RunService:IsServer() then
		return error("GamebeastService.TrackDebugEvent is only available on the server")
	end

	if not self._configService:GetGameConfigData().DebugEnabled.Value then
		return
	end

	return self:TrackEvent(eventName, data)
end

--[[
    Tracks a user event.
]]
function GamebeastService.TrackPlayerEvent(
	self: GamebeastService,
	player: Player,
	eventName: string,
	data: any
): thread?
	if not RunService:IsServer() then
		return error("GamebeastService.TrackPlayerEvent is only available on the server")
	end

	return task.defer(function()
		local markers = Gamebeast:GetService("Markers") :: Gamebeast.MarkersService
		markers:SendPlayerMarker(player, eventName, data)
	end)
end

--[[
    Tracks a user debug event. Won't fire if debug is not enabled.
]]
function GamebeastService.TrackPlayerEventDebug(
	self: GamebeastService,
	player: Player,
	eventName: string,
	data: any
): thread?
	if not RunService:IsServer() then
		return error("GamebeastService.TrackUserDebugEvent is only available on the server")
	end

	if not self._configService:GetGameConfigData().DebugEnabled.Value then
		return
	end

	return self:TrackPlayerEvent(player, eventName, data)
end

--[[
    Observes the config at the given path. Observes the configs ready state and then observes the config at the given path.
]]
function GamebeastService.ObserveConfig<T>(
	self: GamebeastService,
	path: string | { string },
	ignoreNil: boolean?
): Observable.Observable<(T?, T?)>
	local configs = Gamebeast:GetService("Configs") :: Gamebeast.ConfigsService

	return self:ObserveConfigsReady():Pipe({
		Rx.switchMap(function()
			return Observable.new(function(subscriber)
				local maid = Maid.new()

				maid:GiveTask(configs:Observe(path, function(newValue: T, oldValue: T?)
					if (ignoreNil and newValue ~= nil) or not ignoreNil then
						subscriber:Fire(newValue, oldValue)
					end
				end))

				return maid
			end)
		end),
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
function GamebeastService.GetExperimentGroupForPlayer(
	self: GamebeastService,
	player: Player
): { experimentName: string, groupName: string }?
	local experiments = Gamebeast:GetService("Experiments") :: Gamebeast.ExperimentsService

	return experiments:GetGroupForPlayer(player)
end

function GamebeastService.Init(self: GamebeastService, serviceBag: ServiceBag.ServiceBag)
	self._serviceBag = serviceBag
	self._maid = Maid.new()

	self._configService = serviceBag:GetService(ConfigService)
end

function GamebeastService.Start(self: GamebeastService)
	if RunService:IsServer() then
		Gamebeast:Setup({
			key = HttpService:GetSecret("GAMEBEAST_TOKEN"),
		})
	else
		Gamebeast:Setup()
	end
end

return GamebeastService
