@tool
extends Resource
class_name TweenAnimation

@export var root_path: NodePath

var steps: Array

func apply_to_tween(tween: Tween, root: Node):
	root = root.get_node(root_path)
	
	for step: Array in steps:
		for tweener: TweenerAnimator in step:
			tweener.apply_to_tween(tween, root)

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	
	for i in steps.size():
		for j in steps[i].size():
			ret.append({ "name": "step_%d/%d" % [i, j], "type": TYPE_DICTIONARY })
	
	return ret

func _get(property: StringName) -> Variant:
	var idx := get_validated_index(property, false)
	if idx.x == -1:
		return null
	
	return steps[idx.x][idx.y].as_dictionary()

func _set(property: StringName, value: Variant) -> bool:
	var idx := get_validated_index(property, true)
	if idx.x == -1 or not value is Dictionary:
		return false
	
	steps[idx.x][idx.y] = TweenerAnimator.create_from_dictionary(value)
	return true

func get_validated_index(property: String, extend: bool) -> Vector2i:
	var ret := Vector2i(-1, -1)
	if not property.begins_with("step_"):
		return ret
	
	var splits := property.get_slice("_", 1).split("/")
	if splits.size() < 2:
		return ret
	
	if not splits[0].is_valid_int() or not splits[1].is_valid_int():
		return ret
	
	var i := splits[0].to_int()
	var j := splits[1].to_int()
	if i < 0 or j < 0:
		return ret
	
	if extend:
		while i >= steps.size():
			steps.append([])
		
		if j >= steps[i].size():
			steps[i].resize(j + 1)
	else:
		if i >= steps.size() or j >= steps[i].size():
			return ret
	
	ret.x = i
	ret.y = j
	return ret

class TweenerAnimator:
	func get_name() -> String:
		return "Tweener"
	
	func as_dictionary() -> Dictionary:
		return {}
	
	func apply_dictionary(data: Dictionary):
		pass
	
	func apply_to_tween(tween: Tween, root: Node):
		pass
	
	static func create_from_dictionary(data: Dictionary) -> TweenerAnimator:
		var tweener: TweenerAnimator
		
		match data["type"]:
			0:
				tweener = PropertyTweenerAnimator.new()
		
		tweener.apply_dictionary(data)
		return tweener

class PropertyTweenerAnimator extends TweenerAnimator:
	var target: NodePath
	var property: NodePath
	var final_value: Variant
	var duration: float
	
	func get_name() -> String:
		return "Property Tweener"
	
	func as_dictionary() -> Dictionary:
		return {
			"type": 0, ##TODO: enum
			"target": target,
			"property": property,
			"final_value": final_value,
			"duration": duration,
		}
	
	func apply_dictionary(data: Dictionary):
		target = data["target"]
		property = data["property"]
		final_value = data["final_value"]
		duration = data["duration"]
	
	func apply_to_tween(tween: Tween, root: Node):
		tween.tween_property(root.get_node(target), property, final_value, duration)

class IntervalTweenerAnimator extends TweenerAnimator:
	var time: float
	
	func get_name() -> String:
		return "Interval Tweener"
	
	func as_dictionary() -> Dictionary:
		return { "time": time }

class CallbackTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Callback Tweener"

class MethodTweenerAnimator extends TweenerAnimator:
	func get_name() -> String:
		return "Method Tweener"
