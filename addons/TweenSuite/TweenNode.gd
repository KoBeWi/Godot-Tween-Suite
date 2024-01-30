@tool
@icon("uid://brtn2nqtj48pj")
extends Node
class_name TweenNode

const _EARLY_ERROR = "Method called too early, Tween not initialized. Use make_tween() to force early creation."

@export var animation: TweenAnimation:
	set(anime):
		if anime == animation:
			return
		
		animation = anime
		
		if _tween:
			_tween.kill()
			_tween = null
			make_tween()

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

var _tween: Tween

static func create_persistent_tween(with_autostart: bool = false) -> Tween:
	var scene_tree: SceneTree = Engine.get_main_loop()
	var tween := scene_tree.create_tween()
	tween.finished.connect(tween.stop)
	
	if not with_autostart:
		tween.stop()
	
	return tween

func make_tween():
	if _tween:
		return
	
	_tween = TweenNode.create_persistent_tween(autostart)
	_tween.bind_node(self).set_process_mode(tween_process_mode).set_trans(default_transition).set_ease(default_easing).set_pause_mode(pause_mode).set_loops(loops).set_parallel(parallel).set_speed_scale(speed_scale)
	
	if animation:
		animation.apply_to_tween(_tween, self)
	else:
		_initialize_animation(_tween)

func _initialize_animation(tween: Tween):
	pass

func play():
	assert(_tween != null, _EARLY_ERROR)
	_tween.play()

func pause():
	assert(_tween != null, _EARLY_ERROR)
	_tween.pause()

func stop():
	assert(_tween != null, _EARLY_ERROR)
	_tween.stop()

func get_tween() -> Tween:
	assert(_tween != null, _EARLY_ERROR)
	return _tween

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		make_tween.call_deferred()
