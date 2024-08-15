@tool
extends Control

var tweener: TweenAnimation.TweenerAnimator

signal changed

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	fill_transitions(get_data_control("Property", ^"Transition"))
	fill_eases(get_data_control("Property", ^"Ease"))
	fill_transitions(get_data_control("Method", ^"Transition"))
	fill_eases(get_data_control("Method", ^"Ease"))
	update_id()
	
func fill_transitions(button: OptionButton):
	button.add_item("Default")
	button.set_item_id(-1, -1)
	button.add_item("Linear", Tween.TRANS_LINEAR)
	button.add_item("Sine", Tween.TRANS_SINE)
	button.add_item("Quint", Tween.TRANS_QUINT)
	button.add_item("Quart", Tween.TRANS_QUART)
	button.add_item("Quad", Tween.TRANS_QUAD)
	button.add_item("Expo", Tween.TRANS_EXPO)
	button.add_item("Elastic", Tween.TRANS_ELASTIC)
	button.add_item("Cubic", Tween.TRANS_CUBIC)
	button.add_item("Circ", Tween.TRANS_CIRC)
	button.add_item("Bounce", Tween.TRANS_BOUNCE)
	button.add_item("Back", Tween.TRANS_BACK)
	button.add_item("Spring", Tween.TRANS_SPRING)

func fill_eases(button: OptionButton):
	button.add_item("Default")
	button.set_item_id(-1, -1)
	button.add_item("In", Tween.EASE_IN)
	button.add_item("Out", Tween.EASE_OUT)
	button.add_item("In Out", Tween.EASE_IN_OUT)
	button.add_item("Out In", Tween.EASE_OUT_IN)

func set_tweener(tw: TweenAnimation.TweenerAnimator):
	tweener = tw
	%Type.text = tweener.get_name()
	
	if tweener is TweenAnimation.PropertyTweenerAnimator:
		%PropertyTweener.show()
	elif tweener is TweenAnimation.IntervalTweenerAnimator:
		%IntervalTweener.show()
	elif tweener is TweenAnimation.CallbackTweenerAnimator:
		%CallbackTweener.show()
	elif tweener is TweenAnimation.MethodTweenerAnimator:
		%MethodTweener.show()

func get_data() -> TweenAnimation.TweenerAnimator:
	if tweener is TweenAnimation.PropertyTweenerAnimator:
		tweener.target = get_data_control("Property", ^"Object").text
		tweener.property = get_data_control("Property", ^"Property").text
		tweener.final_value = get_data_control("Property", ^"FinalValue").result
		tweener.duration = get_data_control("Property", ^"Duration").value
		tweener.relative = get_data_control("Property", ^"Relative").button_pressed
		tweener.easing = get_data_control("Property", ^"Ease").get_selected_id()
		tweener.transition = get_data_control("Property", ^"Transition").get_selected_id()
		tweener.from_current = get_data_control("Property", ^"FromCurrent").button_pressed
		tweener.from = get_data_control("Property", ^"From").result
		tweener.delay = get_data_control("Property", ^"Delay").value
	elif tweener is TweenAnimation.IntervalTweenerAnimator:
		tweener.time = get_data_control("Interval", ^"Time").value
	elif tweener is TweenAnimation.CallbackTweenerAnimator:
		tweener.target = get_data_control("Callback", ^"Object").text
		tweener.method = get_data_control("Callback", ^"Method").text
		tweener.delay = get_data_control("Callback", ^"Delay").value
	elif tweener is TweenAnimation.MethodTweenerAnimator:
		tweener.target = get_data_control("Method", ^"Object").text
		tweener.method = get_data_control("Method", ^"Method").text
		tweener.from = get_data_control("Method", ^"From").result
		tweener.to = get_data_control("Method", ^"To").result
		tweener.duration = get_data_control("Method", ^"Duration").value
		tweener.easing = get_data_control("Method", ^"Ease").get_selected_id()
		tweener.transition = get_data_control("Method", ^"Transition").get_selected_id()
		tweener.delay = get_data_control("Method", ^"Delay").value
	
	return tweener

func apply_tweener():
	if tweener is TweenAnimation.PropertyTweenerAnimator:
		get_data_control("Property", ^"Object").text = tweener.target
		get_data_control("Property", ^"Property").text = tweener.property
		get_data_control("Property", ^"FinalValue").result = tweener.final_value
		get_data_control("Property", ^"Duration").value = tweener.duration
		get_data_control("Property", ^"Relative").button_pressed = tweener.relative
		set_selected_id(get_data_control("Property", ^"Ease"), tweener.easing)
		set_selected_id(get_data_control("Property", ^"Transition"), tweener.transition)
		get_data_control("Property", ^"FromCurrent").button_pressed = tweener.from_current
		get_data_control("Property", ^"From").result = tweener.from
		get_data_control("Property", ^"Delay").value = tweener.delay
	elif tweener is TweenAnimation.IntervalTweenerAnimator:
		get_data_control("Interval", ^"Time").value = tweener.time
	elif tweener is TweenAnimation.CallbackTweenerAnimator:
		get_data_control("Callback", ^"Object").text = tweener.target
		get_data_control("Callback", ^"Method").text = tweener.method
		get_data_control("Callback", ^"Delay").value = tweener.delay
	elif tweener is TweenAnimation.MethodTweenerAnimator:
		get_data_control("Method", ^"Object").text = tweener.target
		get_data_control("Method", ^"Method").text = tweener.method
		get_data_control("Method", ^"From").result = tweener.from
		get_data_control("Method", ^"To").result = tweener.to
		get_data_control("Method", ^"Duration").value = tweener.duration
		set_selected_id(get_data_control("Method", ^"Ease"), tweener.easing)
		set_selected_id(get_data_control("Method", ^"Transition"), tweener.transition)
		get_data_control("Method", ^"Delay").value = tweener.delay

func get_data_control(tw: String, control: NodePath):
	return get_node("%%%sTweener" % tw).get_node(control)

func set_selected_id(button: OptionButton, id: int):
	for i in button.item_count:
		if button.get_item_id(i) == id:
			button.select(i)
			return
	
	push_error("Wrong ID %d for button %s" % [id, button])

func update_id():
	%ID.format(get_index())

func delete_me() -> void:
	queue_free()
	emit_changed()

func emit_changed():
	changed.emit()

func from_current_toggled(toggled_on: bool) -> void:
	get_data_control("Property", ^"From").editable = not toggled_on

func set_root(root: Node):
	get_data_control("Property", ^"Object").base_node = root
	get_data_control("Callback", ^"Object").base_node = root
	get_data_control("Method", ^"Object").base_node = root
