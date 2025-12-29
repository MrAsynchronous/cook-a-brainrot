local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Binder = require("Binder")
local PlayerPlotBinder = require("PlayerPlotBinder")

local PlotService = {} :: PlotService
PlotService.ServiceName = "PlotService"

export type PlotService = typeof(PlotService) & {
    _serviceBag: ServiceBag.ServiceBag,
    _maid: Maid.Maid,

    _playerPlotBinder: Binder.Binder<PlayerPlotBinder.PlayerPlotBinder>
}

function PlotService.Init(self: PlotService, serviceBag: ServiceBag.ServiceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._maid = Maid.new()

    self._playerPlotBinder = serviceBag:GetService(PlayerPlotBinder) :: Binder.Binder<PlayerPlotBinder.PlayerPlotBinder>

    
    -- self._plots = ObservableList.new() :: ObservableList.ObservableList<PlayerPlot.PlayerPlot>
    -- self._assignedPlots = ObservableMap.new()

    -- self._maid:GiveTask(self._plots)
    -- self._maid:GiveTask(self._assignedPlots)
end

function PlotService.Start(self: PlotService) 
    
    
    -- local plotBinder = self._gameBindersServer:Get("PlayerPlot")

    -- self._maid:GiveTask(plotBinder:ObserveAllBrio():Subscribe(function(brio)
    --     local maid, plot = brio:ToMaidAndValue()

    --     maid:GiveTask(self._plots:Add(plot))
    -- end))

    -- self._maid:GiveTask(Players.PlayerAdded:Connect(function(player)
        
    
    --     print(player.Name, "joined the game!")

    --     print(self._plots:GetCount())

    -- end))

    -- self._maid:GiveTask(Players.PlayerRemoving:Connect(function(player)
        
    -- end))
end

function PlotService:_getFreshPlot()
    local plots = self._plots:GetList()

    for _, plot in plots do
        if (plot:IsAssigned()) then
            continue;
        end

        return plot
    end
    
    return nil
end

return PlotService