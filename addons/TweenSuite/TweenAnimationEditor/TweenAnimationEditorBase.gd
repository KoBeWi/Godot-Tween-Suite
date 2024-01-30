@tool
extends Control

@onready var animation_view: ScrollContainer = $AnimationView

var animation_editor: Control

func create_editor(for_animation: TweenAnimation):
	if animation_editor:
		animation_editor.queue_free()
		animation_editor = null
	
	animation_editor = preload("./TweenAnimationEditor.tscn").instantiate()
	animation_editor.animation = for_animation
	animation_view.add_child(animation_editor)

func new_animation() -> void:
	create_editor(TweenAnimation.new())

func load_animation() -> void:
	var animation: TweenAnimation = ResourceLoader.load("TrueTestAnimation.tres", "TweenAnimation")
	create_editor(animation)

func save_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	ResourceSaver.save(animation, "TrueTestAnimation.tres")
