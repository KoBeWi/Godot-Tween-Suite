@tool
extends Control

enum NewOption { PROPERTY, INTERVAL, CALLBACK, METHOD }

@onready var root_path: LineEdit = %RootPath
@onready var step_container: VBoxContainer = %StepContainer

var animation: TweenAnimation

var animation_steps: Array[Control]

func _ready() -> void:
	for step in animation.steps:
		var step_control := add_animation_step()
		
		for tweener in step:
			add_tweener(step_control, tweener)

func add_animation_step() -> Control:
	var animation_step: Control = preload("./EditorComponents/AnimationStep.tscn").instantiate()
	step_container.add_child(animation_step)
	animation_step.connect_signals(self)
	return animation_step

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
	
	var tweener_editor: Control = preload("./EditorComponents/TweenerEditor.tscn").instantiate()
	tweener_editor.set_tweener(tweener)
	step.add_tweener(tweener_editor)

func add_tweener(step: Control, tweener: TweenAnimation.TweenerAnimator):
	var tweener_editor: Control = preload("./EditorComponents/TweenerEditor.tscn").instantiate()
	tweener_editor.set_tweener(tweener)
	step.add_tweener(tweener_editor)

func push_data():
	animation.root_path = root_path.text
	var steps: Array
	
	for step in step_container.get_children():
		var step_data: Array
		var tweeners: Node = step.tweeners
		
		step_data.resize(tweeners.get_child_count())
		for i in step_data.size():
			step_data[i] = tweeners.get_child(i).get_data()
		
		steps.append(step_data)
	
	animation.steps = steps
