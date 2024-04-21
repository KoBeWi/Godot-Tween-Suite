@tool
extends LineEdit

var sync: bool

var result: Variant:
	set(r):
		result = r
		
		if result == null:
			if not sync:
				text = ""
			tooltip_text = """<null>
Possible input:
Variant constructor (Color(1, 0, 0), "string", Vector2(), etc.)
@property name
$metadata name
"""
		else:
			if not sync:
				text = var_to_str(result)
				if result is String:
					if result.begins_with("@") or result.begins_with("$"):
						text = result
			
			tooltip_text = str(result)
			if result is String:
				if result.begins_with("@"):
					tooltip_text = "Property: \"%s\"" % result.substr(1)
				elif result.begins_with("$"):
					tooltip_text = "Metadata: \"%s\"" % result.substr(1)

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(evaluate)
	
	text_changed.connect(timer.start.unbind(1))

func evaluate():
	var value: Variant
	if text.is_empty():
		value = null
	elif text.begins_with("@") or text.begins_with("$"):
		value = text
	else:
		var expression := Expression.new()
		if expression.parse(text) != OK:
			modulate = Color.RED
			return
		
		value = expression.execute()
		if expression.has_execute_failed():
			modulate = Color.RED
			return
	
	modulate = Color.WHITE
	
	sync = true
	result = value
	sync = false
