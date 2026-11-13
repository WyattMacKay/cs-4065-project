extends Node

@export var timer_display: CustomTimer
@export var all_targets: Array[Target] = []

# TODO implement all data collection
# TODO add music to mole game

var inactive_targets: Array[Target] = []

var spawn_timer: Timer
var score: int = 0
var save_file := "user://savedata.bin"
var score_str: String
var maxscore_str: String
var tween: Tween

var misclick_counter := -1

const DAMAGE := 25
const SPAWN_SPEED_FLOOR := 2.0 # Time between spawns in seconds
const SPAWN_SEED_CEILING := 5.0
const EXPERIMENT_DURATION := 30


func _ready():
	seed(232512020)

	for target: Target in all_targets:
		target.connect("target_hit", _on_hit)
		target.connect("inactive", _on_inactive)

	inactive_targets = all_targets
	update_score()

	spawn_timer = Timer.new()
	spawn_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	spawn_timer.set_one_shot(false)

	add_child(spawn_timer)
	set_process(true)


func _on_hit(_obj: Target, time: int):
	score += 1
	update_score()

	print("# misclicks: %d, time taken: %d" % [misclick_counter, time])
	DataCollector.append_data(misclick_counter, time)
	misclick_counter = -1


func _on_inactive(obj: Target):
	inactive_targets.append(obj)


func gameover():
	end_tween()
	get_node("Panel").show()
	spawn_timer.stop()
	for target: Target in all_targets:
		target.gameover()


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


func end_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()


func reset_tween() -> void:
	end_tween()
	tween = create_tween()


func _on_start_button_pressed() -> void:
	get_node("Panel").hide()
	reset_game_timer()
	timer_display.start()
	score = 0
	misclick_counter = -1

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
	new_timer.timeout.connect(gameover)
	timer_display.timer = new_timer


func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		misclick_counter += 1
	elif (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
