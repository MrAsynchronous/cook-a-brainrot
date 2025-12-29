local require = require(script.Parent.loader).load(script)

local AttributeValue = require("AttributeValue")
local BaseObject = require("BaseObject")
local Maid = require("Maid")
local Binder = require("Binder")

local PlayerPlotBinder = setmetatable({}, BaseObject)
PlayerPlotBinder.__index = PlayerPlotBinder
PlayerPlotBinder.ServiceName = "PlayerPlotBinder"

export type PlayerPlotBinder = typeof(setmetatable(
	{} :: {
		_maid: Maid.Maid
	},
	{} :: typeof({ __index = PlayerPlotBinder })
))

function PlayerPlotBinder.new(instance: Instance)
    local self = {}
    self._maid = Maid.new()

    self._instance = assert(instance, "No instance")

    self._assigned = AttributeValue.new(self._instance, "Assigned", false)
    self._assignedPlayer = AttributeValue.new(self._instance, "AssignedPlayer", nil)

    return setmetatable(self, PlayerPlotBinder)
end

function PlayerPlotBinder.AssignPlayer(self: PlayerPlotBinder, player: Player)
    if (self._assigned.Value) then
        error("Plot is already assigned to a player!")

        return
    end

    self._assigned.Value = true
    self._assignedPlayer.Value = player.Name
end

function PlayerPlotBinder.IsAssigned(self: PlayerPlotBinder): boolean 
    return self._assigned.Value
end

function PlayerPlotBinder.Destroy(self: PlayerPlotBinder)
    self._maid:Destroy()
end

return Binder.new("PlayerPlot", PlayerPlotBinder)