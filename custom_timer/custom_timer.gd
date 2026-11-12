extends Control

class_name CustomTimer

@export var timer_bar: ColorRect
@export var timer: Timer
var initial_bar_length: float
var started := false


func start() -> void:
	assert(timer_bar != null, "TimerBar export variable is null for " + name)
	assert(timer != null, "Timer export variable is null for " + name)
	initial_bar_length = timer_bar.size.x
	started = true


func _process(_delta: float) -> void:
	if started:
		timer_bar.size.x = initial_bar_length * timer.time_left / timer.wait_time
