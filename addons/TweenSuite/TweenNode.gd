@tool
extends Node
class_name TweenNode

@export var animation: TweenAnimation

@export_enum("Idle", "Physics") var tween_process_mode: int
@export_enum("Bound", "Stop", "Process") var pause_mode: int
@export_range(0, 9999) var loops: int = 1
@export var parallel: bool
@export var speed_scale: float = 1.0

var tween: Tween

func _init() -> void:
	tween = create_tween().set_process_mode(tween_process_mode).set_pause_mode(pause_mode).set_loops(loops).set_parallel(parallel).set_speed_scale(speed_scale)
	tween.stop()
	tween.finished.connect(tween.stop)
	
	if animation:
		animation.apply_to_tween(tween)

func play():
	tween.play()

func pause():
	tween.pause()

func stop():
	tween.stop()
