@tool
extends EditorPlugin

var editor: Control

func _enter_tree() -> void:
	editor = preload("./TweenAnimationEditorBase.tscn").instantiate()
	add_control_to_bottom_panel(editor, editor.name)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	editor.queue_free()

func _handles(object: Object) -> bool:
	return object is TweenAnimation

func _edit(object: Object) -> void:
	editor.edit(object)

func _make_visible(visible: bool) -> void:
	if visible:
		make_bottom_panel_item_visible(editor)
	elif editor.is_visible_in_tree():
		hide_bottom_panel()
