#https://github.com/lulersoft/godot_mole_game
#Godot QQ Group: 302924317
#Author:xiaolu (QQ2604904)
extends Node

var target_arr: Array[Target] = []
var timer: Timer
var hp: int = 100
var score: int = 0
var highscore: int = 0
var save_file := "user://savedata.bin"
var score_str = "score: "
var maxscore_str = "best: "
var level = 0
var tween: Tween

const DAMAGE := 25


func _ready():
	randomize()
	for i in range(3):
		target_arr.push_back(get_node("bg" + str(i) + "/mole0"))
		target_arr.push_back(get_node("bg" + str(i) + "/mole1"))
		target_arr.push_back(get_node("bg" + str(i) + "/mole2"))

	for mole: Target in target_arr:
		mole.connect("mole_hit", _on_hit)
		mole.connect("mole_missed", _on_miss)

	highscore = read()
	update_score()
	get_node("maxscore").set_text(maxscore_str + str(highscore))

	timer = Timer.new()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.set_one_shot(false)
	timer.set_wait_time(speed())

	add_child(timer)
	set_process(true)


func _process(_delta):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()


func speed():
	return (10.0 - level) / 10.0


func change_speed():
	level = level + 1
	if (level >= 5):
		level = 5
	timer.set_wait_time(speed())
	print("change game level" + str(speed()))


func _on_hit(_obj: Target):
	score += 1
	update_score()


func _on_miss(_obj: Target):
	hp -= DAMAGE
	update_health()


func gameover():
	end_tween()
	get_node("Panel").show()
	save()
	timer.stop()
	for mole: Target in target_arr:
		mole.gameover()


func _on_timer_timeout():
	emerge_random_target()


func emerge_random_target():
	var idx = randi() % target_arr.size()
	var mole = target_arr[idx]
	if mole.is_moving:
		emerge_random_target()
	else:
		mole.emerge()


func update_score() -> void:
	get_node("score").set_text("Score: " + str(score))
	if highscore < score:
		highscore = score
		get_node("maxscore").set_text(maxscore_str + str(highscore))
	if (score > 0 and score % 25 == 0):
		change_speed()


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
	hp = 100
	score = 0
	level = 0

	for mole: Target in target_arr:
		mole.gamestart()

	update_health()

	timer.set_wait_time(speed())
	timer.start()
