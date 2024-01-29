@tool
extends Node
class_name TweenNode

enum Stage { INIT, ENTER_TREE, POST_ENTER_TREE, READY, MANUAL }

@export var animation: TweenAnimation

@export_group("Initial Settings")
@export var autostart: bool
@export var speed_scale: float = 1.0
@export_enum("Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back", "Sprint") var default_transition: int
@export_enum("In", "Out", "In Out", "Out In") var default_easing: int = Tween.EASE_IN_OUT
@export var parallel: bool

@export_group("Processing Settings")
@export_range(0, 9999) var loops: int = 1
@export_enum("Idle", "Physics") var tween_process_mode: int
@export_enum("Bound", "Stop", "Process") var pause_mode: int
@export var initialization_stage: Stage = Stage.READY

var _tween: Tween

func make_tween():
	if _tween:
		return
	
	var scene_tree: SceneTree = Engine.get_main_loop()
	_tween = scene_tree.create_tween().bind_node(self).set_process_mode(tween_process_mode).set_trans(default_transition).set_ease(default_easing).set_pause_mode(pause_mode).set_loops(loops).set_parallel(parallel).set_speed_scale(speed_scale)
	_tween.finished.connect(_tween.stop)

	if not autostart:
		_tween.stop()
	
	if animation:
		animation.apply_to_tween(_tween)
	else:
		_initialize_animation(_tween)

func _init() -> void:
	if initialization_stage == Stage.INIT:
		make_tween()

func _notification(what: int) -> void:
	if _tween:
		return
	
	if what == NOTIFICATION_ENTER_TREE and initialization_stage == Stage.ENTER_TREE:
		make_tween()
	elif what == NOTIFICATION_POST_ENTER_TREE and initialization_stage == Stage.POST_ENTER_TREE:
		make_tween()
	elif what == NOTIFICATION_READY and initialization_stage == Stage.READY:
		make_tween()

func _initialize_animation(tween: Tween):
	pass

func play():
	_tween.play()

func pause():
	_tween.pause()

func stop():
	_tween.stop()

func get_tween() -> Tween:
	return _tween
