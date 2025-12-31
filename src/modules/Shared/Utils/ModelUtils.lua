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

function ModelUtils.setModelCanCollide(model: Model, canCollide: boolean)
	for _, descendant in model:GetDescendants() do
		if not descendant:IsA("BasePart") then
			continue
		end

		descendant.CanCollide = canCollide
	end
end

return ModelUtils
