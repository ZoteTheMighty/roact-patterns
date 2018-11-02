# Roact Gamepad Example
This is an example of using gamepads in Roact. Right now, this example is built on a version of Roact that has Bindings implemented, which reduces the need for incredibly convoluted workarounds.

## First Class Refs
First-class refs enable the use of refs to lazily bind object references, which is useful for interfacing with Roblox's gamepad API.

Using a version of the Roact reconciler with bindings built into it, selection management in Roact can look like this:

```lua
local TwoHalves = Roact.Component:extend("TwoHalves")

function TwoHalves:init()
	self.leftRef = Roact.createRef()
	self.rightRef = Roact.createRef()
end

function TwoHalves:render()
	return Roact.createElement("Frame", nil, {
		Left = Roact.createElement("TextButton", {
			Text = "Left",
			SelectionRight = self.rightRef,

			[Roact.Ref] = self.leftRef,
		}),

		Right = Roact.createElement("TextButton", {
			Text = "Right",
			SelectionLeft = self.leftRef,

			[Roact.Ref] = self.rightRef,
		}),
	})
end
```

The `SelectionLeft` and `SelectionRight` properties of each value will be lazily populated when the other control is constructed.

For more complicated selection trees, libraries and patterns like `createRefCache()` and `NavigationController` will probably still be relevant, but should be much simpler to build.

## NavigationController and FocusHost
These objects help provide more sophisticated focus management and action bindings to Roact trees.

More to come....