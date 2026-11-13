extends Target

# TODO gameover animation

var original_pos: Vector2
var destination_pos: Vector2
var tween: Tween

const DELAY: float = 0.3
const TWEEN_TIME: float = 0.1


func _ready():
	super._ready()
	original_pos = position
	destination_pos = Vector2(original_pos.x, original_pos.y - 60)


func gamestart():
	super.gamestart()
	position = original_pos


func gameover():
	end_tween()
	# TODO make gameover animation


func emerge():
	super.emerge()
	reset_tween()
	get_node("anim").play("run")
	tween.tween_property(self, "position", destination_pos, TWEEN_TIME) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN)


func on_click():
	super.on_click()
	reset_tween()
	tween.tween_callback(submerge).set_delay(DELAY)
	play_audio(click_sound)
	get_node("anim").play("die")


func submerge():
	reset_tween()

	tween.tween_property(self, "position", original_pos, TWEEN_TIME) \
			.set_delay(DELAY) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN)

	tween.tween_callback(on_missed_hit_opportunity)


func on_missed_hit_opportunity():
	is_moving = false
	inactive.emit(self)


func end_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()


func reset_tween() -> void:
	end_tween()
	tween = create_tween()


func play_stimulus() -> void:
	const DURATION_MS := 100
	const AMPLITUDE := 0.25
	Input.vibrate_handheld(DURATION_MS, AMPLITUDE)
	play_audio(appear_sound)


func play_audio(audio: AudioStream):
	audio_player.stream = audio
	audio_player.play()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		on_click()
