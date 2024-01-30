@tool
extends Control

var tweener: TweenAnimation.TweenerAnimator

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	fill_transitions(get_data_control("Property", ^"Transition"))
	fill_eases(get_data_control("Property", ^"Ease"))
	fill_transitions(get_data_control("Method", ^"Transition"))
	fill_eases(get_data_control("Method", ^"Ease"))
	
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
		tweener.transition = get_data_control("Property", ^"Transition").get_selected_id()
		tweener.from_current = get_data_control("Property", ^"FromCurrent").button_pressed
		tweener.from = get_data_control("Property", ^"From").result
		tweener.delay = get_data_control("Property", ^"Delay").value
	elif tweener is TweenAnimation.IntervalTweenerAnimator:
		tweener.time = get_data_control("Interval", ^"Time").text
	elif tweener is TweenAnimation.CallbackTweenerAnimator:
		tweener.target = get_data_control("Callback", ^"Object").text
		tweener.method = get_data_control("Callback", ^"Method").text
		tweener.delay = get_data_control("Callback", ^"Delay").text
	elif tweener is TweenAnimation.MethodTweenerAnimator:
		pass
	
	return tweener

func get_data_control(tw: String, control: NodePath):
	return get_node("%%%sTweener" % tw).get_node(control)
