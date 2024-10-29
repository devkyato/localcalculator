local function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

local function evaluateExpression(expression)
	local operators = { ["+"] = true, ["-"] = true, ["*"] = true, ["/"] = true }
	local numbers = {}
	local operations = {}

	local function applyOperation()
		local b = table.remove(numbers)
		local a = table.remove(numbers)
		local op = table.remove(operations)
		if op == "+" then
			table.insert(numbers, a + b)
		elseif op == "-" then
			table.insert(numbers, a - b)
		elseif op == "*" then
			table.insert(numbers, a * b)
		elseif op == "/" then
			if b == 0 then
				return nil, "Division by zero"
			end
			table.insert(numbers, a / b)
		end
	end

	local i = 1
	while i <= #expression do
		local char = expression:sub(i, i)
		if char:match("%d") or (char == "." and i < #expression and expression:sub(i + 1, i + 1):match("%d")) then
			local num = ""
			while i <= #expression and (expression:sub(i, i):match("[%d.]")) do
				num = num .. expression:sub(i, i)
				i = i + 1
			end
			table.insert(numbers, tonumber(num))
			i = i - 1
		elseif operators[char] then
			while #operations > 0 and ((operations[#operations] == "*" or operations[#operations] == "/") or (char == "+" or char == "-")) do
				applyOperation()
			end
			table.insert(operations, char)
		end
		i = i + 1
	end

	while #operations > 0 do
		applyOperation()
	end

	if #numbers == 1 then
		return numbers[1]
	else
		return nil, "Invalid expression"
	end
end

local function calculatorReducer(state, action)
	state = state or {
		input = "",
		previousInput = nil,
		operation = nil,
		result = nil,
		history = {}
	}

	if action.type == "ADD" or action.type == "SUBTRACT" or action.type == "MULTIPLY" or action.type == "DIVIDE" then
		local newState = shallowCopy(state)
		table.insert(newState.history, action.value)
		newState.input = state.input .. action.value
		return newState

	elseif action.type == "CLEAR" then
		return {
			input = "",
			previousInput = nil,
			operation = nil,
			result = nil,
			history = state.history 
		}

	elseif action.type == "EQUAL" then
		local result, err = evaluateExpression(state.input)
		if not result then
			return {
				input = "Error",
				result = nil,
				previousInput = state.previousInput,
				operation = state.operation,
				history = state.history
			}
		else
			local newState = shallowCopy(state)
			table.insert(newState.history, "=" .. tostring(result))
			newState.result = result
			newState.input = tostring(result)
			return newState
		end
	else
		return state
	end
end

return calculatorReducer