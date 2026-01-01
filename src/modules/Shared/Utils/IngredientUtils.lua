local require = require(script.Parent.loader).load(script)

local IngredientUtils = {}
IngredientUtils.ServiceName = "IngredientUtils"

function IngredientUtils.isIngredient(instance: Instance): boolean
	return instance:GetAttribute("Type") == "Ingredient"
end

return IngredientUtils
