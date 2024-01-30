@tool
extends Control

@onready var animation_view: ScrollContainer = $AnimationView

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
	
	%Play.disabled = false
	%Stop.disabled = false

func new_animation() -> void:
	create_editor(TweenAnimation.new())

func load_animation() -> void:
	var animation: TweenAnimation = ResourceLoader.load("TrueTestAnimation.tres", "TweenAnimation")
	create_editor(animation)

func save_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	ResourceSaver.save(animation, "TrueTestAnimation.tres")

func play_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	
	create_revert(animation)
	
	preview_tween= create_tween()
	animation.apply_to_tween(preview_tween, EditorInterface.get_edited_scene_root())

func stop_animation() -> void:
	preview_tween.kill()
	preview_tween = null

func create_revert(from: TweenAnimation):
	pass

func apply_revert():
	pass
