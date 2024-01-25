@tool
extends VBoxContainer

@onready var tweeners: HBoxContainer = %Tweeners

func connect_signals(editor: Control):
	%AddTweener.get_popup().id_pressed.connect(editor.on_new_tweener.bind(self))

func add_tweener(tweener: Control):
	tweeners.add_child(tweener)
