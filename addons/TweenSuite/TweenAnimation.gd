@tool
extends Resource
class_name TweenAnimation

var _steps: Array

var steps: Array:
	set(s):
		pass
	get:
		return _steps

var root: Node

func apply_to_tween(tween: Tween):
	pass

func _validate_property(property: Dictionary) -> void:
	if property.name == "steps":
		property.usage |= PROPERTY_USAGE_STORAGE

class TweenerAnimator:
	func get_name() -> String:
		return "Tweener"

class PropertyTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Property Tweener"

class IntervalTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Interval Tweener"

class CallbackTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Callback Tweener"

class MethodTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Method Tweener"
