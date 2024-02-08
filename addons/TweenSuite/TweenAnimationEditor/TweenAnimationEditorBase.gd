@tool
extends Control

@onready var animation_view: ScrollContainer = $AnimationView
@onready var root_path_edit: HBoxContainer = %RootPathEdit
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
	
	update_root(".")

func create_editor(for_animation: TweenAnimation):
	if animation_editor:
		stop_animation()
		animation_editor.queue_free()
		animation_editor = null
	
	if not for_animation:
		update_play()
		return
	
	animation_editor = preload("./TweenAnimationEditor.tscn").instantiate()
	animation_editor.animation = for_animation
	animation_view.add_child(animation_editor)
	animation_editor.expanded.connect(scroll_to_infinity, CONNECT_DEFERRED)
	
	update_root()

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
	
	var root: Node = root_path_edit.object
	animation = create_revert(animation, root)
	
	preview_tween = create_tween()
	animation.apply_to_tween(preview_tween, root)
	preview_tween.finished.connect(apply_revert)
	
	# FIXME: There is currently no other way to check if Tween didn't fail.
	await get_tree().create_timer(0.1).timeout
	
	if not is_zero_approx(preview_tween.get_total_elapsed_time()):
		stop_button.disabled = false

func stop_animation() -> void:
	if not preview_tween:
		return
	
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
	root_path_edit.base_node = EditorInterface.get_edited_scene_root()
	
	if new_text.is_empty():
		new_text = root_path_edit.text
	
	root_path = new_text
	root_path_edit.text = new_text
	root_valid = root_path_edit.object != null and root_path_edit.object is Node
	
	if animation_editor:
		if root_valid:
			animation_editor.set_root(root_path_edit.object)
		else:
			animation_editor.set_root(null)
	
	update_play()

func update_play():
	play_button.disabled = not root_valid or not animation_editor

func save_data():
	if animation_editor:
		animation_editor.push_data()

func scroll_to_infinity():
	await get_tree().process_frame
	animation_view.scroll_horizontal = 99999999
