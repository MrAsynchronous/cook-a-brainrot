local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Observable = require("Observable")

local RxChildUtils = {}
RxChildUtils.ServiceName = "RxChildUtils"

function RxChildUtils.observeChildCount(parent: Instance): Observable.Observable<number>
	return Observable.new(function(subscriber)
		local maid = Maid.new()

		local function handleChildrenChanged()
			subscriber:Fire(#parent:GetChildren())
		end

		maid:GiveTask(parent.ChildAdded:Connect(handleChildrenChanged))
		maid:GiveTask(parent.ChildRemoved:Connect(handleChildrenChanged))

		subscriber:Fire(#parent:GetChildren())

		return maid
	end)
end

return RxChildUtils
