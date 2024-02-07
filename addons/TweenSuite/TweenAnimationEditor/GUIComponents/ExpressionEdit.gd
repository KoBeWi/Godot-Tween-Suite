@tool
extends LineEdit

var sync: bool

var result: Variant:
	set(r):
		result = r
		
		if result == null:
			if not sync:
				text = ""
			tooltip_text = "null"
		else:
			if not sync:
				text = var_to_str(result)
			tooltip_text = str(result)

func _ready() -> void:
	text_changed.connect(evaluate.unbind(1)) ## TODO: debouncing

func evaluate():
	if text.is_empty():
		result = null
		modulate = Color.WHITE
		return
	
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
