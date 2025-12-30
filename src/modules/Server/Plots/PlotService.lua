local require = require(script.Parent.loader).load(script)

local Workspace = game:GetService("Workspace")

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Blend = require("Blend")
local RxPlayerUtils = require("RxPlayerUtils")
local RxCharacterUtils = require("RxCharacterUtils")

local PlotService = {} :: PlotService
PlotService.ServiceName = "PlotService"

export type PlotService = typeof(PlotService) & {
    _serviceBag: ServiceBag.ServiceBag,
    _maid: Maid.Maid,
    _plotFolder: Folder,
}

function PlotService.Init(self: PlotService, serviceBag: ServiceBag.ServiceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._maid = Maid.new()

    local gameFolder = Workspace:WaitForChild("Game")
    self._plotFolder = gameFolder:WaitForChild("Plots")
end

function PlotService.Start(self: PlotService)
    self._maid:GiveTask(RxPlayerUtils.observePlayersBrio():Subscribe(function(brio)
        local maid, player: Player = brio:ToMaidAndValue()

        local freePlot = self:_getFreshPlot()

        freePlot:SetAttribute("PlayerName", player.Name)
        freePlot:AddTag("PlayerRestaurant")

        maid:GiveTask(Blend.New "ObjectValue" {
            Name = "Plot",
            Value = freePlot,
        }:Subscribe(function(objectValue)
            objectValue.Parent = player
        end))

        maid:GiveTask(RxCharacterUtils.observeCharacter(player):Subscribe(function(character: Model)
            if (not character) then
                return
            end
    
            local playerSpawnPart = freePlot:FindFirstChild("PlayerSpawn")

            character:PivotTo(playerSpawnPart:GetPivot() + Vector3.new(0, 5, 0))
        end))

        maid:GiveTask(function()
            freePlot:SetAttribute("PlayerName", nil)
            freePlot:RemoveTag("PlayerRestaurant")
        end)
    end))
end

function PlotService._getFreshPlot(self: PlotService): Model?
    local plots = self._plotFolder:GetChildren()

    for _, plot in plots do
        if (plot:HasTag("PlayerRestaurant")) then
            continue;
        end

        return plot
    end
    
    return nil
end

return PlotService