local require = require(script.Parent.loader).load(script)

local PlayerUtils = {}
PlayerUtils.ServiceName = "PlayerUtils"

function PlayerUtils.getPlayerPlot(player: Player): Model?
	local plot = player:FindFirstChild("Plot") :: ObjectValue?
	if not plot then
		return nil
	end

	return plot.Value
end

return PlayerUtils
