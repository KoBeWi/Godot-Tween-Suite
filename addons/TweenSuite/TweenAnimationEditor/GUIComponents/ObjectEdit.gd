@tool
extends Control

@onready var icon: TextureRect = $Icon
@onready var path: LineEdit = $Path

var text: String:
	set(t):
		path.text = t
		update_object()
	get:
		return path.text

var base_node: Node:
	set(bn):
		base_node = bn
		update_object()

var object: Object
var update_queued: bool

signal object_changed

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	update_object()
	path.set_drag_forwarding(Callable(), can_drop_node, drop_node)

func update_object():
	if update_queued:
		return
	
	update_queued = true
	_update_object.call_deferred()

func _update_object():
	update_queued = false
	
	if base_node and not text.is_empty():
		if text.contains(":"):
			object = TweenAnimation.TweenerAnimator.get_target_object(base_node, text)
		else:
			object = base_node.get_node_or_null(text)
	else:
		object = null
	
	object_changed.emit()
	
	if object:
		icon.texture = EditorInterface.get_editor_theme().get_icon(object.get_class(), &"EditorIcons")
		path.modulate = Color.WHITE
		
		if object is Node:
			icon.tooltip_text = object.name
		else:
			icon.tooltip_text = object.to_string()
	else:
		icon.texture = EditorInterface.get_editor_theme().get_icon(&"MissingNode", &"EditorIcons")
		icon.tooltip_text = ""
		path.modulate = Color.RED

func can_drop_node(pos: Vector2, data: Variant) -> bool:
	var root := EditorInterface.get_edited_scene_root()
	if not root:
		return false
	
	if data.get("type", "") != "nodes":
		return false
	
	var paths: Array = data.get("nodes", [])
	if paths.size() != 1:
		return false
	
	var node: Node = get_tree().root.get_node(paths[0])
	if not root.is_ancestor_of(node):
		return false
	
	return true

func drop_node(pos: Vector2, data: Variant):
	var node: Node = get_tree().root.get_node(data["nodes"][0])
	text = base_node.get_path_to(node)

func pick_node() -> void:
	EditorInterface.popup_node_selector(node_picked)

func node_picked(path: NodePath):
	var node := get_tree().edited_scene_root.get_node_or_null(path)
	if node:
		text = base_node.get_path_to(node)
