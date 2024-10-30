-- CalculatorUI.lua
-- Made by dev.mako

-- This script contains the entire code for a Roact-based calculator UI, including
-- the UI setup, Redux-like state management for calculations, and action definitions.
-- This is for the HiddenDevs 

--===== Dependencies =====
local Roact = require(game.ReplicatedStorage.Roact)
local Rodux = require(game.ReplicatedStorage.Rodux)
local TweenService = game:GetService("TweenService")

-- Actions and Reducer modules for managing state
local Actions = {} -- Actions table to hold action functions
local function calculatorReducer(state, action) -- Reducer function for state management end

--===== Actions Section =====
-- This section defines calculator actions for different arithmetic operations and controls.

Actions.add = function(value) return { type = "ADD", value = value } end
Actions.subtract = function(value) return { type = "SUBTRACT", value = value } end
Actions.multiply = function(value) return { type = "MULTIPLY", value = value } end
Actions.divide = function(value) return { type = "DIVIDE", value = value } end
Actions.clear = function() return { type = "CLEAR" } end
Actions.equal = function() return { type = "EQUAL" } end

--===== Reducer Section =====
-- The reducer manages the calculator’s state, handling actions like adding values, clearing input, and evaluating expressions.

-- Deep copy helper function
local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

-- Expression evaluation function
local function evaluateExpression(expression)
    local operators = { ["+"] = true, ["-"] = true, ["*"] = true, ["/"] = true }
    local numbers, operations = {}, {}

    -- Apply the last operation in the operations stack
    local function applyOperation()
        local b, a, op = table.remove(numbers), table.remove(numbers), table.remove(operations)
        if op == "+" then table.insert(numbers, a + b)
        elseif op == "-" then table.insert(numbers, a - b)
        elseif op == "*" then table.insert(numbers, a * b)
        elseif op == "/" then
            if b == 0 then return nil, "Division by zero" end
            table.insert(numbers, a / b)
        end
    end

    -- Parse expression
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

    while #operations > 0 do applyOperation() end
    if #numbers == 1 then return numbers[1] else return nil, "Invalid expression" end
end

-- Reducer function for managing state based on actions dispatched
local function calculatorReducer(state, action)
    state = state or { input = "", previousInput = nil, operation = nil, result = nil, history = {} }
    if action.type == "ADD" or action.type == "SUBTRACT" or action.type == "MULTIPLY" or action.type == "DIVIDE" then
        local newState = shallowCopy(state)
        table.insert(newState.history, action.value)
        newState.input = state.input .. action.value
        return newState
    elseif action.type == "CLEAR" then
        return { input = "", previousInput = nil, operation = nil, result = nil, history = state.history }
    elseif action.type == "EQUAL" then
        local result, err = evaluateExpression(state.input)
        if not result then
            return { input = "Error", result = nil, previousInput = state.previousInput, operation = state.operation, history = state.history }
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

--===== Calculator UI Section =====
-- This section defines the calculator UI, including buttons, input display, and grid layout.

local CalculatorUI = {}
local store = Rodux.Store.new(calculatorReducer)

local CalculatorComponent = Roact.Component:extend("CalculatorComponent")

function CalculatorComponent:init()
    self:setState({ currentInput = store:getState().input })
    self.storeConnection = store.changed:connect(function(newState)
        self:setState({ currentInput = newState.input })
    end)
end

function CalculatorComponent:willUnmount()
    self.storeConnection:disconnect()
end

local function CalculatorButton(props)
    local buttonRef = Roact.createRef()
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function onHover()
        local buttonInstance = buttonRef:getValue()
        if buttonInstance then
            local hoverTween = TweenService:Create(buttonInstance, tweenInfo, { BackgroundColor3 = Color3.fromRGB(210, 210, 210) })
            hoverTween:Play()
        end
    end

    local function onLeave()
        local buttonInstance = buttonRef:getValue()
        if buttonInstance then
            local leaveTween = TweenService:Create(buttonInstance, tweenInfo, { BackgroundColor3 = Color3.fromRGB(240, 240, 240) })
            leaveTween:Play()
        end
    end

    local function onClick()
        local buttonInstance = buttonRef:getValue()
        if buttonInstance then
            local clickTween = TweenService:Create(buttonInstance, tweenInfo, { BackgroundColor3 = Color3.fromRGB(180, 180, 180) })
            clickTween:Play()
            clickTween.Completed:Connect(onLeave)
        end
        props.onClick()
    end

    return Roact.createElement("TextButton", {
        [Roact.Ref] = buttonRef,
        Text = props.label,
        Size = UDim2.new(0.23, -10, 0.23, -10),
        BackgroundColor3 = Color3.fromRGB(240, 240, 240),
        TextColor3 = Color3.fromRGB(50, 50, 50),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        [Roact.Event.MouseEnter] = onHover,
        [Roact.Event.MouseLeave] = onLeave,
        [Roact.Event.MouseButton1Click] = onClick,
    }, {
        UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),
        UIStroke = Roact.createElement("UIStroke", { Color = Color3.fromRGB(200, 200, 200), Thickness = 1 })
    })
end

function CalculatorComponent:render()
    local buttonLabels = {
        { "1", Actions.add("1") }, { "2", Actions.add("2") }, { "3", Actions.add("3") }, { "+", Actions.add("+") },
        { "4", Actions.add("4") }, { "5", Actions.add("5") }, { "6", Actions.add("6") }, { "-", Actions.add("-") },
        { "7", Actions.add("7") }, { "8", Actions.add("8") }, { "9", Actions.add("9") }, { "*", Actions.add("*") },
        { "C", Actions.clear() }, { "0", Actions.add("0") }, { "=", Actions.equal() }, { "/", Actions.add("/") }
    }

    local buttonElements = {}
    for i, button in ipairs(buttonLabels) do
        table.insert(buttonElements, Roact.createElement(CalculatorButton, {
            label = button[1],
            onClick = function() store:dispatch(button[2]) end,
            LayoutOrder = i
        }))
    end

    return Roact.createElement("ScreenGui", {}, {
        MainFrame = Roact.createElement("Frame", {
            Size = UDim2.new(0.3, 0, 0.5, 0),
            Position = UDim2.new(0.35, 0, 0.25, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }, {
            DisplayFrame = Roact.createElement("Frame", { Size = UDim2.new(1, 0, 0.2, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 30) }, {
                Display = Roact.createElement("TextLabel", { Text = self.state.currentInput, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(255, 255, 255), TextScaled = true })
            }),
            ButtonGrid = Roact.createElement("Frame", { Size = UDim2.new(1, 0, 0.8, 0), Position = UDim2.new(0, 0, 0.2, 0), BackgroundTransparency = 1 }, {
                GridLayout = Roact.createElement("UIGridLayout", { CellSize = UDim2.new(0.23, -5, 0.23, -5), CellPadding = UDim2.new(0.02, 0, 0.02, 0), SortOrder = Enum.SortOrder.LayoutOrder }),
                Buttons = Roact.createFragment(buttonElements)
            })
        })
    })
end

function CalculatorUI.new(target: Instance)
    local handle = Roact.mount(Roact.createElement(CalculatorComponent), target, "CalculatorUI")
    return function() Roact.unmount(handle) end
end

return CalculatorUI
