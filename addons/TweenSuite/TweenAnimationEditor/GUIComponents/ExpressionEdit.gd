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
	var expression := Expression.new()
	if expression.parse(text) != OK:
		modulate = Color.RED
		return
	
	var value: Variant = expression.execute()
	if expression.has_execute_failed():
		modulate = Color.RED
		return
	
	modulate = Color.WHITE
	
	sync = true
	result = value
	sync = false
	tooltip_text = str(result)
