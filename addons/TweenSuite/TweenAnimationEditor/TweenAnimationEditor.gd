@tool
extends Control

enum NewOption { PROPERTY, INTERVAL, CALLBACK, METHOD }

@onready var step_container: BoxContainer = %StepContainer

var root_valid: bool

var animation: TweenAnimation

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	for step in animation.steps:
		var step_control := add_animation_step()
		
		for tweener in step:
			add_tweener(step_control, tweener)

func add_animation_step() -> Control:
	var animation_step: Control = preload("./EditorComponents/AnimationStep.tscn").instantiate()
	step_container.add_child(animation_step)
	animation_step.connect_signals(self)
	return animation_step

func update_step_headers():
	for step in step_container.get_children():
		step.update_header()

func on_new_tweener(id: int, step: Control):
	var tweener: TweenAnimation.TweenerAnimator
	
	match id:
		NewOption.PROPERTY:
			tweener = TweenAnimation.PropertyTweenerAnimator.new()
		NewOption.INTERVAL:
			tweener = TweenAnimation.IntervalTweenerAnimator.new()
		NewOption.CALLBACK:
			tweener = TweenAnimation.CallbackTweenerAnimator.new()
		NewOption.METHOD:
			tweener = TweenAnimation.MethodTweenerAnimator.new()
	
	add_tweener(step, tweener)

func add_tweener(step: Control, tweener: TweenAnimation.TweenerAnimator):
	var tweener_editor: Control = preload("./EditorComponents/TweenerEditor.tscn").instantiate()
	tweener_editor.set_tweener(tweener)
	step.add_tweener(tweener_editor)

func push_data():
	var steps: Array
	
	for step in step_container.get_children():
		var step_data: Array
		var tweeners: Node = step.tweeners
		
		step_data.resize(tweeners.get_child_count())
		for i in step_data.size():
			step_data[i] = tweeners.get_child(i).get_data()
		
		steps.append(step_data)
	
	animation.steps = steps
