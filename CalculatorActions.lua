local Actions = {}

Actions.add = function(value) return { type = "ADD", value = value } end
Actions.subtract = function(value) return { type = "SUBTRACT", value = value } end
Actions.multiply = function(value) return { type = "MULTIPLY", value = value } end
Actions.divide = function(value) return { type = "DIVIDE", value = value } end
Actions.clear = function() return { type = "CLEAR" } end
Actions.equal = function() return { type = "EQUAL" } end

return Actions