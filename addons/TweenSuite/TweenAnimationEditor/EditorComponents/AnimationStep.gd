@tool
extends Control

@onready var tweeners: BoxContainer = %Tweeners
@onready var add_tweener_button: MenuButton = %AddTweener

@onready var header_label: Label = %HeaderLabel
@onready var move_left: Button = %MoveLeft
@onready var move_right: Button = %MoveRight

signal deleted
signal move_requested(step)

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	
	update_header()
	
	for style: StringName in [&"normal", &"pressed", &"hover", &"disabled", &"focus"]:
		add_tweener_button.add_theme_stylebox_override(style, get_theme_stylebox(style, &"OptionButton"))
	
	add_theme_stylebox_override(&"panel", get_theme_stylebox(&"panel", &"TreeSecondary"))

func connect_signals(editor: Control):
	add_tweener_button.get_popup().id_pressed.connect(editor.on_new_tweener.bind(self))
	tree_exited.connect(editor.update_step_headers)
	deleted.connect(editor.push_data_delayed)
	move_requested.connect(editor.move_step.bind(self))

func add_tweener(tweener: Control):
	tweeners.add_child(tweener)
	tweener.tree_exited.connect(update_tweener_headers)

func update_header():
	var idx := get_index()
	header_label.format(idx)
	move_left.disabled = idx == 0
	move_right.disabled = idx == get_parent().get_child_count() - 1

func update_tweener_headers():
	for tweener in tweeners.get_children():
		tweener.update_id()

func delete_me() -> void:
	deleted.emit()
	queue_free()

func _move_left() -> void:
	move_requested.emit(-1)

func _move_right() -> void:
	move_requested.emit(1)
