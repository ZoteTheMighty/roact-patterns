# Roact Gamepad Example
This is an example of using gamepads in Roact. Right now, this example is built on a version of Roact that has Bindings implemented, which reduces the need for incredibly convoluted workarounds.

## First-class Refs
First-class refs enable the use of refs to lazily bind object references, which is useful for interfacing with Roblox's gamepad API.

Using a version of the Roact reconciler with First-class Refs built into it, selection management in Roact can look like this:

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

## Navigation API
The `NavigationController` and `FocusHost` objects help provide more sophisticated focus management and action bindings to Roact trees. These objects are intended to be used together, and are not useful separately.

#### createNavigationController
```
createNavigationController() -> NavigationController
```
`NavigationController` is a controller object that manages focus and selection across an entire Roact tree (it will usually passed around through context). At any given time, a single group of elements, defined by a `FocusHost`, can contain the current selection. Selection within a focused `FocusHost` will use the above selection methods.

#### createFocusHost
```
createFocusHost(hostRef, [childRefs]) -> FocusHost
```
The `FocusHost` object is a virtual collection of UI elements that can be regarded as a single group. When a `FocusHost` has focus, gamepad selection occurs among its children and some additional configuration is applied.

Create a focus host by providing a ref to the parent container. Optionally, provide a list or table of refs (all of the table's values must be refs) to restrict which children are selection targets. The created object can be configured via the methods detailed below.

### FocusHost API

#### setSelectionRule
```
setSelectionRule(selectionRule) -> void
```
where `selectionRule` is a function with the signature:
```
selectionRule(lastSelected) -> newSelection
```
Sets the rule for determining the initial selection when focus is given to this `FocusHost`. If this `FocusHost` has been previously focused, `lastSelection` will be the Roblox instance that was last selected when focus was lost. Otherwise, it will be nil.

This function can be used to specify a default selection, persist selection after losing and regaining focus, or specify selection based on some custom logic or external values.

Note that both the provided `lastSelection` value and the returned value must be *Roblox Instances* rather than refs.

The following is an example of a selection rule that provides a default for the initial focus and then persists for all focuses after:
```lua
myFocusHost:setSelectionRule(function(lastSelection)
	if lastSelection == nil then
		return myDefaultSelectionRef.current
	end

	return lastSelection
end)
```

#### setContextAction
```
setContextAction(id, handler, inputs...) -> void
```
Adds a new contextual action with the given handler and inputs. These actions will be bound and unbound using `ContextActionService` whenever a `FocusHost` gains or loses focus. Because of this, any contextual actions specified this way will only be bound while the user is selecting within the group.

### NavigationController API

#### mountFocusHost
```
mountFocusHost(focusHost) -> void
```
Registers a focus host created using `createFocusHost`. Once this is called, the given group will be able to receive focus using the `navigateTo` method. This method should be called in a component's `didMount` method.

#### unmountFocusHost
```
unmountFocusHost(focusHost) -> void
```
De-registers a focus host and cleans it up, making it no longer available to receive focus. This method should be called in a component's `willUnmount` method.

#### navigateTo
```
navigateTo(hostRef) -> void
```
Moves focus to the `FocusHost` associated with the given host ref. This method triggers the following sequence of events:
1. Currently-focused `FocusHost` loses focus
	a. Unbinds context actions
	b. Calls GuiService:RemoveSelectionGroup for associated Instance
2. `FocusHost` associated with given hostRef gains focus
	a. Binds context actions
	b. Calls GuiService:AddSelectionParent or GuiService:AddSelectionTuple for associated Instance(s)
	c. Sets initial selection according to rule provided with `setSelectionRule`

## Future Development
The tools provided by these navigation solutions should make some navigation paradigms easier to implement. In particular, the example provided shows a reasonable implementation of a view pager, with support for changing views with left and right bumpers. It also includes a component with a variable-length list of buttons, which connects those buttons together using First-class Refs.

Other patterns may be more or less difficult than the ones implemented here. Further investigation is needed to identify missing features or shortcomings. Below is a short list of any currently known issues and absences.

### Concerns with Current Implementation
* Passing refs around is awkward and opaque, particularly when refs have unclear ownership. This could be addressed at the Roact level, or by establishing some convention, or by some other pattern not yet discovered.
* The examples depend on passing a `NavigationController` through context, but then using it in `didMount`/`willUnmount`. This makes it a poor candidate for the render-prop Provider/Consumer pattern.
* Currently, there's some fallback selection logic that's awkward and potentially flaky, and doesn't account for selection tuples at all. This should be replaced with something more thought out.

### Missing Features or Improvements
* Some operations would benefit from being able to reverse-lookup a ref when given an instance, but since it also supports auto-navigation, the user may not have created refs for all relevant Instances.
* Context actions use the standard ContextActionService interface, but don't provide any particular insight for determining which Instance in a group is selected. Utilities to determine which element in a list is selected when a context action is invoked are crucial to making the feature useful.
* There needs to be an interface layer between this navigation framework and `ContextActionService`/`GuiService` that allows use of the "Core" versions of the methods and fields used. This is crucial to making it useful for internal code.
* It would be nice to provide a simple way to get common selection rules (defaultTo, persistOrDefaultTo)