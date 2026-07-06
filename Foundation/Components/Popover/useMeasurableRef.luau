local Foundation = script.Parent.Parent.Parent
local PackageManager = require(Foundation.PackageManager)

local Signal = PackageManager.getPackage("Signal")

local Utility = Foundation.Utility

local unwrap = require(Utility.unwrap)
local Types = require(Utility.Types)

type UsedAs<T> = Types.UsedAs<T>
type Scope = Types.Scope

type MeasurableObjectSignal<T> = Types.MeasurableObjectSignal<T>
type Signal<T> = Types.Signal<T>
type FireSignal<T> = Types.FireSignal<T>

type SignalWrapper<T> = { signal: MeasurableObjectSignal<T>, fire: FireSignal<T> }

type BaseMeasurableObjectImpl = {
	__index: BaseMeasurableObjectImpl,
	new: (position: Vector2, size: Vector2) -> BaseMeasurableObject,
	SetPosition: (self: BaseMeasurableObject, position: Vector2) -> (),
	SetSize: (self: BaseMeasurableObject, size: Vector2) -> (),
	GetPropertyChangedSignal: (self: BaseMeasurableObject, propertyName: string) -> Signal<unknown>,
}

type BaseMeasurableObject = typeof(setmetatable(
	{} :: {
		_signals: {
			AbsolutePosition: SignalWrapper<Vector2>,
			AbsoluteSize: SignalWrapper<Vector2>,
		},
		AbsolutePosition: Vector2,
		AbsoluteSize: Vector2,
	},
	{} :: BaseMeasurableObjectImpl
	))

local function createSignal<T>(): SignalWrapper<T>
	local signal, fire = Signal.createSignal()

	local self = {} :: MeasurableObjectSignal<T>

	function self.Connect(_, callback: (value: T) -> ())
		local subscription = signal:subscribe(callback)

		local connection = {
			Disconnect = function()
				subscription:unsubscribe()
			end,
		}

		return connection
	end

	return { signal = self, fire = fire }
end

local MeasurableObject = {} :: BaseMeasurableObjectImpl
MeasurableObject.__index = MeasurableObject

function MeasurableObject.new(position: Vector2, size: Vector2)
	local self = setmetatable({
		AbsolutePosition = position,
		AbsoluteSize = size,
		_signals = {},
	}, MeasurableObject)

	self._signals.AbsolutePosition = createSignal()
	self._signals.AbsoluteSize = createSignal()

	return self
end

function MeasurableObject:GetPropertyChangedSignal(propertyName: string): Signal<any>
	if self._signals[propertyName] then
		return self._signals[propertyName].signal
	end
	error(`{propertyName} is not a valid property name.`)
end

function MeasurableObject:SetPosition(newPosition: Vector2)
	if self.AbsolutePosition ~= newPosition then
		self.AbsolutePosition = newPosition
		self._signals.AbsolutePosition.fire(newPosition)
	end
end

function MeasurableObject:SetSize(newSize: Vector2)
	if self.AbsoluteSize ~= newSize then
		self.AbsoluteSize = newSize
		self._signals.AbsoluteSize.fire(newSize)
	end
end

return function(scope: Scope, position: UsedAs<Vector2>, size: UsedAs<Vector2?>): UsedAs<BaseMeasurableObject>
	local initialPosition = unwrap(position)
	local initialSize = unwrap(size) or Vector2.one

	local instance = MeasurableObject.new(initialPosition, initialSize)
	local instanceValue = scope:Value(instance)

	local function syncPosition()
		instance:SetPosition(unwrap(position))
	end

	local function syncSize()
		instance:SetSize(unwrap(size) or Vector2.one)
	end

	if unwrap(position) ~= position then
		scope:Observer(position):onChange(syncPosition)
	end

	if unwrap(size) ~= size then
		scope:Observer(size):onChange(syncSize)
	end

	syncPosition()
	syncSize()

	return instanceValue
end