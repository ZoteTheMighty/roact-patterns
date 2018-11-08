local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Roact = require(Modules.Roact)
local Gamepad = require(Modules.Gamepad)

local assign = require(script.Parent.assign)

local function asFocusGroup(containerComponent)

	local Container = Roact.Component:extend("Container")

	function Container:init()
		self.nav = self._context[Gamepad]
	end

	function Container:render()
		local onSelectionGained = self.props[Roact.Event.SelectionGained]

		local finalProps = assign({}, self.props, {
			host = Roact.None,
			[Roact.Event.SelectionGained] = function(...)
				onSelectionGained(...)

				self.nav:navigateTo(self.host)
			end
		})

		return Roact.createElement(containerComponent, finalProps)
	end

	function Container:didMount()
		local host = self.props[Roact.Ref]

		local default = self.props.default
		local persist = self.props.persist

		local navRules = self.props.navRules

		local focusHost = self.nav:mountFocusHost(host)

		focusHost:setDefault(default)
		focusHost:setPersist(persist)

		for button, handler in pairs(navRules) do
			focusHost:setNavRule(tostring(button), handler, button)
		end
	end

	function Container:willUnmount()
		local host = self.props.host

		self.nav:unmountFocusHost(host)
	end

	return Container
end

return asFocusGroup