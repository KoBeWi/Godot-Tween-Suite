@tool
extends EditorPlugin

var editor: Control

func _enter_tree() -> void:
	editor = preload("./TweenAnimationEditor.tscn").instantiate()
	add_control_to_bottom_panel(editor, editor.name)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	editor.queue_free()
