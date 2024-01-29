@tool
extends HBoxContainer

@onready var animation_view: ScrollContainer = $AnimationView

var animation_editor: Control

func new_animation() -> void:
	if animation_editor:
		animation_editor.queue_free()
		animation_editor = null
	
	animation_editor = preload("./TweenAnimationEditor.tscn").instantiate()
	animation_view.add_child(animation_editor)
