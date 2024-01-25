@tool
extends HBoxContainer

enum NewOption { PROPERTY, INTERVAL, CALLBACK, METHOD }

@onready var step_container: VBoxContainer = %StepContainer

var animation: TweenAnimation

var animation_steps: Array[Control]

func _ready() -> void:
	animation = TweenAnimation.new()

func add_animation_step() -> void:
	var animation_step: Control = preload("./AnimationStep.tscn").instantiate()
	step_container.add_child(animation_step)
	animation_step.connect_signals(self)

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
	
	var tweener_editor: Control = preload("./TweenerEditor.tscn").instantiate()
	tweener_editor.set_tweener(tweener)
	
	step.add_tweener(tweener_editor)
