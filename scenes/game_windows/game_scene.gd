#https://github.com/lulersoft/godot_mole_game
#Godot QQ Group: 302924317
#Author:xiaolu (QQ2604904)
extends Node

@export var timer_display: CustomTimer
@export var all_targets: Array[Target] = []

# TODO play sound on click
# TODO vibrate on click
# TODO count misses
# TODO get click speed
# TODO mobile data collection
# TODO use a set seed
# TODO randomize spawn rate

var inactive_targets: Array[Target] = []

var timer: Timer
var score: int = 0
var save_file := "user://savedata.bin"
var score_str: String
var maxscore_str: String
var tween: Tween

const DAMAGE := 25
const SPAWN_SPEED := .75 # Time between spawns in seconds
const EXPERIMENT_DURATION := 30


func _ready():
	randomize()

	for target: Target in all_targets:
		target.connect("target_hit", _on_hit)
		target.connect("inactive", _on_inactive)

	inactive_targets = all_targets

	update_score()

	timer = Timer.new()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.set_one_shot(false)
	timer.set_wait_time(SPAWN_SPEED)

	add_child(timer)
	set_process(true)


func _process(_delta):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()


func _on_hit(_obj: Target):
	score += 1
	update_score()


func _on_inactive(obj: Target):
	inactive_targets.append(obj)


func gameover():
	end_tween()
	get_node("Panel").show()
	timer.stop()
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

# Commented out for future use in saving user data
#func save():
#var f: FileAccess = FileAccess.open_encrypted_with_pass(save_file, FileAccess.WRITE, "godot")
#if (!f):
#return
#f.store_64(highscore)
#f.close()
#
#
#func read():
#var v = 0
#if FileAccess.file_exists(save_file):
#var f := FileAccess.open_encrypted_with_pass(save_file, FileAccess.READ, "godot")
#v = f.get_64()
#f.close()
#return v


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

	for target: Target in all_targets:
		target.gamestart()

	timer.set_wait_time(SPAWN_SPEED)
	timer.start()


func reset_game_timer() -> void:
	var new_timer := Timer.new()
	add_child(new_timer)
	new_timer.one_shot = true
	new_timer.start(EXPERIMENT_DURATION)
	new_timer.timeout.connect(gameover)
	timer_display.timer = new_timer
