local Roact = require(game.ReplicatedStorage.Roact)
local Rodux = require(game.ReplicatedStorage.Rodux)
local TweenService = game:GetService("TweenService")
local Actions = require(game.ReplicatedStorage.LocalCalculator.CalculatorActions)
local reducer = require(game.ReplicatedStorage.LocalCalculator.CalculationReducer)

export type CalculatorUI = {
	new: (target: Instance) -> (() -> ())
}

local CalculatorUI = {}
local store = Rodux.Store.new(reducer)

local CalculatorComponent = Roact.Component:extend("CalculatorComponent")

function CalculatorComponent:init()
	self:setState({
		currentInput = store:getState().input
	})
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
			clickTween.Completed:Connect(function()
				onLeave()
			end)
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
		BackgroundTransparency = 0.1,
		[Roact.Event.MouseEnter] = onHover,
		[Roact.Event.MouseLeave] = onLeave,
		[Roact.Event.MouseButton1Click] = onClick,
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(200, 200, 200),
			Thickness = 1,
		}),
	})
end

function CalculatorComponent:render()
	local buttonLabels = {
		{ "1", Actions.add("1") }, { "2", Actions.add("2") }, { "3", Actions.add("3") }, { "+", Actions.add("+") },
		{ "4", Actions.add("4") }, { "5", Actions.add("5") }, { "6", Actions.add("6") }, { "-", Actions.add("-") },
		{ "7", Actions.add("7") }, { "8", Actions.add("8") }, { "9", Actions.add("9") }, { "*", Actions.add("*") },
		{ "C", Actions.clear() }, { "0", Actions.add("0") }, { "=", Actions.equal() }, { "/", Actions.add("/") },
	}

	local buttonElements = {}
	for i, button in ipairs(buttonLabels) do
		table.insert(buttonElements, Roact.createElement(CalculatorButton, {
			label = button[1],
			onClick = function()
				store:dispatch(button[2])
			end,
			LayoutOrder = i
		}))
	end

	return Roact.createElement("ScreenGui", {}, {
		MainFrame = Roact.createElement("Frame", {
			Size = UDim2.new(0.3, 0, 0.5, 0),
			Position = UDim2.new(0.35, 0, 0.25, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(200, 200, 200),
				Thickness = 1.5,
			}),

			DisplayFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.2, 0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Display = Roact.createElement("TextLabel", {
					Text = self.state.currentInput,
					Size = UDim2.new(1, 0, 1, 0),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					Font = Enum.Font.GothamBold,
					BackgroundTransparency = 1,
				})
			}),

			ButtonGrid = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.8, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
				BackgroundTransparency = 1,
			}, {
				GridLayout = Roact.createElement("UIGridLayout", {
					CellSize = UDim2.new(0.23, -5, 0.23, -5),
					CellPadding = UDim2.new(0.02, 0, 0.02, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Buttons = Roact.createFragment(buttonElements),
			})
		})
	})
end

function CalculatorUI.new(target: Instance)
	local handle = Roact.mount(Roact.createElement(CalculatorComponent), target, "CalculatorUI")
	return function()
		Roact.unmount(handle)
	end
end

return CalculatorUI :: CalculatorUI