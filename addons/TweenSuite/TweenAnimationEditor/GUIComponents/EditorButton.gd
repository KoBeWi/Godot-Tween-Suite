@tool
extends Button

@export var icon_name: StringName:
	set(iconame):
		if iconame == icon_name:
			return
		
		icon_name = iconame
		if not Engine.is_editor_hint() or not is_inside_tree():
			return
		
		_update_icon()

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_icon()

func _update_icon():
	icon = EditorInterface.get_editor_theme().get_icon(icon_name, &"EditorIcons")

func _validate_property(property: Dictionary) -> void:
	if property.name == "icon":
		property.usage = PROPERTY_USAGE_NONE
