@tool
extends LineEdit

var sync: bool

var result: Variant:
	set(r):
		result = r
		if not sync:
			text = var_to_str(result)

func _ready() -> void:
	text_changed.connect(evaluate.unbind(1)) ## TODO: debouncing

func evaluate():
	sync = true
	result = str_to_var(text)
	sync = false
	tooltip_text = str(result)
