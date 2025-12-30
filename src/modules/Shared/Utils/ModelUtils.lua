local ModelUtils = {}
ModelUtils.ServiceName = ModelUtils

function ModelUtils.setModelAnchored(model: Model, anchored: boolean)
	for _, descendant in model:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.Anchored = anchored
	end
end

return ModelUtils
