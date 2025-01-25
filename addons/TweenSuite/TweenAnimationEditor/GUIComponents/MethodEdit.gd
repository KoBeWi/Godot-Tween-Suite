@tool
extends Control

@export var object_edit: Node

@onready var method_name: LineEdit = $MethodName
@onready var pick_button: Button = $PickButton

var text: String:
	set(t):
		method_name.text = t
	get:
		return method_name.text

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	object_edit.object_changed.connect(update_button)

func update_button():
	pick_button.disabled = object_edit.object == null

func pick_property() -> void:
	EditorInterface.popup_method_selector(object_edit.object, method_picked, text)

func method_picked(method: StringName):
	if not method.is_empty():
		text = method
