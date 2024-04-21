## The resource that defines [Tween] animations.
##
## [TweenAnimation] can be used to animate [Tween] node without using code. You can edit the animation in the [code]Tweens[/code] bottom tab when the resource is selected. Once created, the animation can be applied to a tween to create all [Tweener]s as defined in the animation. You can either use it with a [TweenNode] or a regular tween by calling [method apply_to_tween].
@tool
@icon("uid://dp7rsgqw46he6")
extends Resource
class_name TweenAnimation

var steps: Array

## Applies this animation to the given [Tween]. The [param root] is the base node for animation paths. Called automatically when using [TweenNode].
## [codeblock]
## var tween = create_tween()
## var animation = load("res://tween_animation.tres")
## animation.apply_to_tween(tween, self)
## [/codeblock]
func apply_to_tween(tween: Tween, root: Node):
	for step: Array in steps:
		var first := true
		
		for tweener: TweenerAnimator in step:
			if first:
				first = false
			else:
				tween.parallel()
			
			tweener.apply_to_tween(tween, root)

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	
	for i in steps.size():
		for j in steps[i].size():
			ret.append({ "name": "step_%d/%d" % [i, j], "type": TYPE_DICTIONARY, "usage": PROPERTY_USAGE_STORAGE })
	
	return ret

func _get(property: StringName) -> Variant:
	var idx := _get_validated_index(property, false)
	if idx.x == -1:
		return null
	
	return steps[idx.x][idx.y].as_dictionary()

func _set(property: StringName, value: Variant) -> bool:
	var idx := _get_validated_index(property, true)
	if idx.x == -1 or not value is Dictionary:
		return false
	
	steps[idx.x][idx.y] = TweenerAnimator.create_from_dictionary(value)
	return true

func _get_validated_index(property: String, extend: bool) -> Vector2i:
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
	enum Type { PROPERTY, INTERVAL, CALLBACK, METHOD }
	
	var type: Type
	
	func get_name() -> String:
		return "Tweener"
	
	func as_dictionary() -> Dictionary:
		var ret := {}
		
		for property in get_property_list():
			if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
				var propname: String = property["name"]
				ret[propname] = get(propname)
		
		return ret
	
	func apply_dictionary(data: Dictionary):
		for property in data:
			set(property, data[property])
	
	func apply_to_tween(tween: Tween, root: Node):
		pass
	
	static func get_target_object(root: Node, path: NodePath) -> Object:
		var object_candidates := root.get_node_and_resource(path)
		if object_candidates[1]:
			return object_candidates[1]
		else:
			return object_candidates[0]
	
	static func create_from_dictionary(data: Dictionary) -> TweenerAnimator:
		var tweener: TweenerAnimator
		
		match data["type"]:
			PropertyTweenerAnimator.Type.PROPERTY:
				tweener = PropertyTweenerAnimator.new()
			PropertyTweenerAnimator.Type.INTERVAL:
				tweener = IntervalTweenerAnimator.new()
			PropertyTweenerAnimator.Type.CALLBACK:
				tweener = CallbackTweenerAnimator.new()
			PropertyTweenerAnimator.Type.METHOD:
				tweener = MethodTweenerAnimator.new()
		
		tweener.apply_dictionary(data)
		return tweener
	
	static func evaluate(data: Variant, object: Object) -> Variant:
		if data is String:
			if data.begins_with("@"):
				return object.get(data.substr(1))
			elif data.begins_with("$"):
				return object.get_meta(data.substr(1))
		
		return data

class PropertyTweenerAnimator extends TweenerAnimator:
	var target: NodePath
	var property: NodePath
	var final_value: Variant
	var duration: float
	var relative: bool
	var easing: int
	var transition: int
	var from_current: bool
	var from: Variant
	var delay: float
	
	func _init() -> void:
		type = Type.PROPERTY
	
	func get_name() -> String:
		return "Property Tweener"
	
	func apply_to_tween(tween: Tween, root: Node):
		var object := TweenerAnimator.get_target_object(root, target)
		
		var final_final_value: Variant = TweenerAnimator.evaluate(final_value, object)
		var tweener := tween.tween_property(object, property, final_final_value, duration).set_delay(delay)
		if relative:
			tweener.as_relative()
		
		if easing > -1:
			tweener.set_ease(easing)
		if transition > -1:
			tweener.set_trans(transition)
		
		if from_current:
			tweener.from_current()
		elif from != null:
			var final_from: Variant = TweenerAnimator.evaluate(from, object)
			tweener.from(final_from)

class IntervalTweenerAnimator extends TweenerAnimator:
	var time: float
	
	func _init() -> void:
		type = Type.INTERVAL
	
	func get_name() -> String:
		return "Interval Tweener"
	
	func apply_to_tween(tween: Tween, root: Node):
		tween.tween_interval(time)

class CallbackTweenerAnimator extends TweenerAnimator:
	var target: NodePath
	var method: StringName
	var delay: float
	
	func _init() -> void:
		type = Type.CALLBACK
	
	func get_name() -> String:
		return "Callback Tweener"
	
	func apply_to_tween(tween: Tween, root: Node):
		tween.tween_callback(Callable(TweenerAnimator.get_target_object(root, target), method)).set_delay(delay)

class MethodTweenerAnimator extends TweenerAnimator:
	var target: NodePath
	var method: StringName
	var from: Variant
	var to: Variant
	var duration: float
	var easing: int
	var transition: int
	var delay: float
	
	func _init() -> void:
		type = Type.METHOD
	
	func get_name() -> String:
		return "Method Tweener"
	
	func apply_to_tween(tween: Tween, root: Node):
		var target := TweenerAnimator.get_target_object(root, target)
		var final_from := TweenerAnimator.evaluate(from, target)
		var final_to := TweenerAnimator.evaluate(to, target)
		var tweener := tween.tween_method(Callable(target, method), final_from, final_to, duration).set_delay(delay)
		
		if easing > -1:
			tweener.set_ease(easing)
		if transition > -1:
			tweener.set_trans(transition)
