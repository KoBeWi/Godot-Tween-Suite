@tool
extends LineEdit

var result: Variant

func _ready() -> void:
	text_changed.connect(evaluate.unbind(1)) ## TODO: debouncing

func evaluate():
	result = str_to_var(text)
	tooltip_text = str(result)
