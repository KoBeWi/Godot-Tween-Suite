@tool
extends EditorPlugin

var editor: Control
var editor_button: Button

func _enter_tree() -> void:
	editor = preload("./TweenAnimationEditorBase.tscn").instantiate()
	scene_changed.connect(editor.update_root.unbind(1))
	editor_button = add_control_to_bottom_panel(editor, editor.name)
	editor_button.hide()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	editor.queue_free()

func _handles(object: Object) -> bool:
	if object is TweenNode:
		editor.set_node(object)
	
	return object is TweenAnimation

func _edit(object: Object) -> void:
	editor.edit(object)

func _make_visible(visible: bool) -> void:
	editor_button.visible = visible
	if visible:
		make_bottom_panel_item_visible(editor)
	elif editor.is_visible_in_tree():
		hide_bottom_panel()

func _save_external_data() -> void:
	editor.save_data()
