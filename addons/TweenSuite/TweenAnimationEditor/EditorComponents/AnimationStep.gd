@tool
extends VBoxContainer

@onready var tweeners: HBoxContainer = %Tweeners

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	for style: StringName in [&"normal", &"pressed", &"hover", &"disabled", &"focus"]:
		%AddTweener.add_theme_stylebox_override(style, get_theme_stylebox(style, &"OptionButton"))

func connect_signals(editor: Control):
	%AddTweener.get_popup().id_pressed.connect(editor.on_new_tweener.bind(self))

func add_tweener(tweener: Control):
	tweeners.add_child(tweener)
