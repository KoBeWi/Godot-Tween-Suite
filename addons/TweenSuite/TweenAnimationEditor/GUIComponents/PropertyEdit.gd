@tool
extends Control

@export var object_edit: Node

@onready var property_name: LineEdit = $PropertyName
@onready var pick_button: Button = $PickButton

var text: String:
	set(t):
		property_name.text = t
	get:
		return property_name.text

func _ready() -> void:
	object_edit.object_changed.connect(update_button)

func update_button():
	pick_button.disabled = object_edit.object == null

func pick_property() -> void:
	EditorInterface.popup_property_selector(object_edit.object, property_picked)

func property_picked(path: NodePath):
	if not path.is_empty():
		text = path
