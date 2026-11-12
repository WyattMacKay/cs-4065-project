#https://github.com/lulersoft/godot_mole_game
#Godot QQ Group: 302924317
#Author:xiaolu (QQ2604904)
extends Node

@export var timer_display: CustomTimer

var target_arr: Array[Target] = []
var timer: Timer
var hp: int = 100
var score: int = 0
var highscore: int = 0
var save_file := "user://savedata.bin"
var score_str: String
var maxscore_str: String
var tween: Tween

const DAMAGE := 25
const SPAWN_SPEED := 1
const EXPERIMENT_DURATION := 30


func _ready():
	randomize()
	for i in range(3):
		target_arr.push_back(get_node("bg" + str(i) + "/mole0"))
		target_arr.push_back(get_node("bg" + str(i) + "/mole1"))
		target_arr.push_back(get_node("bg" + str(i) + "/mole2"))

	for target: Target in target_arr:
		target.connect("target_hit", _on_hit)

	highscore = read()
	update_score()
	update_highscore()

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


func gameover():
	end_tween()
	get_node("Panel").show()
	save()
	timer.stop()
	for target: Target in target_arr:
		target.gameover()


func _on_timer_timeout():
	emerge_random_target()


func emerge_random_target():
	var idx = randi() % target_arr.size()
	var target = target_arr[idx]
	if target.is_moving:
		emerge_random_target()
	else:
		target.emerge()


func update_score() -> void:
	get_node("score").set_text("Score: " + str(score))
	if highscore < score:
		highscore = score
		update_highscore()


func update_highscore() -> void:
	get_node("maxscore").set_text("Best: " + str(highscore))


func update_health() -> void:
	if hp < 0:
		hp = 0
	get_node("hp").set_value(hp)
	if hp == 0:
		gameover()


func save():
	var f: FileAccess = FileAccess.open_encrypted_with_pass(save_file, FileAccess.WRITE, "godot")
	if (!f):
		return
	f.store_64(highscore)
	f.close()


func read():
	var v = 0
	if FileAccess.file_exists(save_file):
		var f := FileAccess.open_encrypted_with_pass(save_file, FileAccess.READ, "godot")
		v = f.get_64()
		f.close()
	return v


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
	hp = 100
	score = 0

	for target: Target in target_arr:
		target.gamestart()

	update_health()
	timer.set_wait_time(SPAWN_SPEED)
	timer.start()


func reset_game_timer() -> void:
	var new_timer := Timer.new()
	add_child(new_timer)
	new_timer.one_shot = true
	new_timer.start(EXPERIMENT_DURATION)
	timer_display.timer = new_timer
