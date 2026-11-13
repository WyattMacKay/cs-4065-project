extends Node

@export var collection_method: String
@export var timer_display: CustomTimer
@export var all_targets: Array[Target] = []
@export var end_panel: Panel

var inactive_targets: Array[Target] = []

var spawn_timer: Timer
var score: int = 0
var score_str: String
var maxscore_str: String

var misclick_counter := -1
var trial_count := 0

const SPAWN_SPEED_FLOOR := 2.0 # Time between spawns in seconds
const SPAWN_SEED_CEILING := 5.0
const EXPERIMENT_DURATION := 300 # Entire experiment time in seconds
const MAIN_MENU := "res://scenes/game_windows/main/main_window.tscn"


func _ready():
	seed(232512020)

	for target: Target in all_targets:
		target.connect("target_hit", _on_hit)
		target.connect("inactive", _on_inactive)

	inactive_targets = all_targets.duplicate()
	update_score()

	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	spawn_timer.set_one_shot(false)

	end_panel.hide()
	add_child(spawn_timer)
	set_process(true)


func _on_hit(obj: Target, time: int):
	score += 1
	update_score()
	trial_count += 1
	var trial_num: int = all_targets.find(obj) + 1

	DataCollector.append_data(collection_method, trial_count, trial_num, misclick_counter, time)
	misclick_counter = -1


func _on_inactive(obj: Target):
	inactive_targets.append(obj)
	check_if_complete()


func check_if_complete() -> void:
	if (timer_display.timer.is_stopped() and inactive_targets.size() == all_targets.size()):
		gameover()


func gameover():
	spawn_timer.stop()
	for target: Target in all_targets:
		target.gameover()
	end_panel.show()


func _on_timer_timeout():
	emerge_random_target()


func emerge_random_target():
	if inactive_targets.is_empty():
		return
	var idx = randi() % inactive_targets.size()
	var target = inactive_targets[idx]
	target.emerge()
	inactive_targets.erase(target)


func update_score() -> void:
	get_node("score").set_text("Score: " + str(score))


func _on_start_button_pressed() -> void:
	get_node("Panel").hide()
	reset_game_timer()
	timer_display.start()
	score = 0
	misclick_counter = -1
	trial_count = 0

	for target: Target in all_targets:
		target.gamestart()
	reset_spawn_timer()


func reset_spawn_timer() -> void:
	var wait_time = randf() * (SPAWN_SEED_CEILING - SPAWN_SPEED_FLOOR) + SPAWN_SPEED_FLOOR
	spawn_timer.start(wait_time)


func reset_game_timer() -> void:
	var new_timer := Timer.new()
	add_child(new_timer)
	new_timer.one_shot = true
	new_timer.start(EXPERIMENT_DURATION)
	new_timer.timeout.connect(spawn_timer.stop)
	new_timer.timeout.connect(check_if_complete)
	timer_display.timer = new_timer


func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		misclick_counter += 1
	elif (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
