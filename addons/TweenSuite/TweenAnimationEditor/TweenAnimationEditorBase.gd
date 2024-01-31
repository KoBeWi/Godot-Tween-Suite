@tool
extends Control

@onready var animation_view: ScrollContainer = $AnimationView
@onready var play_button: Button = %Play
@onready var stop_button: Button = %Stop

var animation_editor: Control
var preview_tween: Tween
var revert: Dictionary

func create_editor(for_animation: TweenAnimation):
	if animation_editor:
		animation_editor.queue_free()
		animation_editor = null
	
	animation_editor = preload("./TweenAnimationEditor.tscn").instantiate()
	animation_editor.animation = for_animation
	animation_view.add_child(animation_editor)
	
	play_button.disabled = false

func new_animation() -> void:
	create_editor(TweenAnimation.new())

func load_animation() -> void:
	var animation: TweenAnimation = ResourceLoader.load("TrueTestAnimation.tres", "TweenAnimation")
	create_editor(animation)

func edit(animation: TweenAnimation):
	create_editor(animation)

func save_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	ResourceSaver.save(animation, "TrueTestAnimation.tres")

func play_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	
	var root := EditorInterface.get_edited_scene_root()
	var animation_root := root.get_node(animation.root_path)
	animation = create_revert(animation, animation_root)
	
	preview_tween = create_tween()
	animation.apply_to_tween(preview_tween, root)
	preview_tween.finished.connect(apply_revert)
	
	stop_button.disabled = false

func stop_animation() -> void:
	preview_tween.kill()
	preview_tween = null
	apply_revert()

func create_revert(from: TweenAnimation, animation_root: Node) -> TweenAnimation:
	var new_anim := TweenAnimation.new()
	new_anim.root_path = from.root_path
	var new_steps := []
	
	for step: Array in from.steps:
		new_steps.append(step.filter(func(tweener) -> bool:
			return tweener is TweenAnimation.PropertyTweenerAnimator or tweener is TweenAnimation.IntervalTweenerAnimator))
		
		for tweener in new_steps.back():
			if tweener is TweenAnimation.PropertyTweenerAnimator:
				var target: Object = tweener.get_target_object(animation_root, tweener.target)
				revert[[target, tweener.property]] = target.get_indexed(tweener.property)
	
	new_anim.steps = new_steps
	return new_anim

func apply_revert():
	for key: Array in revert:
		var object: Object = key[0]
		var property: NodePath = key[1]
		object.set_indexed(property, revert[key])
	
	revert.clear()
	stop_button.disabled = true
