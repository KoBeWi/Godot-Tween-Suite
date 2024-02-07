@tool
extends Control

@onready var root_icon: TextureRect = %RootIcon
@onready var root_path_edit: LineEdit = %RootPath

@onready var animation_view: ScrollContainer = $AnimationView
@onready var play_button: Button = %Play
@onready var stop_button: Button = %Stop

var animation_editor: Control

var root_path: NodePath
var root_valid: bool
var preview_tween: Tween
var revert: Dictionary

func _ready() -> void:
	if EditorInterface.get_edited_scene_root() == self:
		return
	
	update_root()

func create_editor(for_animation: TweenAnimation):
	if animation_editor:
		animation_editor.queue_free()
		animation_editor = null
	
	if not for_animation:
		update_play()
		return
	
	animation_editor = preload("./TweenAnimationEditor.tscn").instantiate()
	animation_editor.animation = for_animation
	animation_view.add_child(animation_editor)
	animation_editor.expanded.connect(scroll_to_infinity, CONNECT_DEFERRED)
	
	update_play()

func edit(animation: TweenAnimation):
	create_editor(animation)

func set_node(node: TweenNode):
	var root := node.get_node_or_null(node.animation_root)
	if root:
		root_path_edit.text = EditorInterface.get_edited_scene_root().get_path_to(root)
		update_root()

func play_animation() -> void:
	animation_editor.push_data()
	var animation: TweenAnimation = animation_editor.animation
	
	var root := get_root_node()
	animation = create_revert(animation, root)
	
	preview_tween = create_tween()
	animation.apply_to_tween(preview_tween, root)
	preview_tween.finished.connect(apply_revert)
	
	stop_button.disabled = false

func stop_animation() -> void:
	preview_tween.kill()
	preview_tween = null
	apply_revert()

func create_revert(from: TweenAnimation, animation_root: Node) -> TweenAnimation:
	var new_anim := TweenAnimation.new()
	var new_steps := []
	
	for step: Array in from.steps:
		new_steps.append(step.filter(func(tweener) -> bool:
			return tweener is TweenAnimation.PropertyTweenerAnimator or tweener is TweenAnimation.IntervalTweenerAnimator))
		
		for tweener in new_steps.back():
			if tweener is TweenAnimation.PropertyTweenerAnimator:
				var target: Object = tweener.get_target_object(animation_root, tweener.target)
				revert[[target, tweener.property]] = target.get_indexed(tweener.property)
	
	new_anim.steps = new_steps
	return new_anim

func apply_revert():
	for key: Array in revert:
		var object: Object = key[0]
		var property: NodePath = key[1]
		object.set_indexed(property, revert[key])
	
	revert.clear()
	stop_button.disabled = true

func update_root(new_text: String = "") -> void:
	if new_text.is_empty():
		new_text = root_path_edit.text
	
	root_path = new_text
	
	var root := get_root_node()
	root_valid = root != null
	
	if root_valid:
		root_path_edit.modulate = Color.WHITE
		root_icon.texture = EditorInterface.get_editor_theme().get_icon(root.get_class(), &"EditorIcons")
		root_icon.tooltip_text = root.name
	else:
		root_path_edit.modulate = Color.RED
		root_icon.texture = null
		root_icon.tooltip_text = ""
	
	update_play()

func update_play():
	play_button.disabled = not root_valid and animation_editor != null and animation_editor.root_valid

func get_root_node() -> Node:
	var root := EditorInterface.get_edited_scene_root()
	if root:
		return root.get_node_or_null(root_path)
	return null

func save_data():
	if animation_editor:
		animation_editor.push_data()

func scroll_to_infinity():
	await get_tree().process_frame
	animation_view.scroll_horizontal = 99999999
