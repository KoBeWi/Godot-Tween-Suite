@tool
extends Control

var tweener: TweenAnimation.TweenerAnimator

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
		tweener.final_value = str_to_var(get_data_control("Property", ^"FinalValue").text)
		tweener.duration = get_data_control("Property", ^"Duration").value
	
	return tweener

func get_data_control(tw: String, control: NodePath):
	return get_node("%%%sTweener" % tw).get_node(control)
