# Roblox Calculator with Roact and Rodux

A simple calculator for Roblox using **Roact** for the UI and **Rodux** for state management. Supports basic operations (addition, subtraction, multiplication, division) with a reactive UI.

## Project Overview

This calculator demonstrates Roact and Rodux integration for handling UI components and state management in Roblox.

## Setup

1. **Clone this repo** and ensure the following files are in `ReplicatedStorage`:
   - `CalculatorUI.lua`
   - `CalculatorActions.lua`
   - `CalculationReducer.lua`
2. **Install Dependencies**: Add **Roact** and **Rodux** to `ReplicatedStorage`.

## File Structure

- **CalculatorUI.lua**: Defines UI components and connects them to Rodux.
- **CalculatorActions.lua**: Defines actions like `add`, `clear`, and `equal`.
- **CalculationReducer.lua**: Manages calculator state, handling actions and evaluating expressions.

## Components

1. **CalculatorUI.lua**:
   - **CalculatorComponent**: Main UI component, connects to the Rodux store.
   - **CalculatorButton**: Custom button with hover/click animations.
   - **UI Layout**: Structured display and button grid layout for the calculator interface.

2. **CalculatorActions.lua**: Contains actions:
   - `add(value)`, `clear()`, `equal()` – Define operations for managing input.

3. **CalculationReducer.lua**:
   - **Reducer Logic**: Handles actions (`ADD`, `EQUAL`, `CLEAR`) to update the state.
   - **Helper Functions**:
     - `evaluateExpression(expression)`: Evaluates arithmetic expressions.

## Usage

- **Initialize**: Call `CalculatorUI.new(target)` to mount UI to a target.
- **Interact**: Use calculator buttons for calculations; the UI updates via state changes in Rodux.
