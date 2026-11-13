@abstract
extends AnimatedSprite2D

class_name Target

@export var audio_player: AudioStreamPlayer
@export var appear_sound: AudioStream
@export var click_sound: AudioStream
@export var click_area: Area2D

var is_moving := false
var is_hittable := false

var time_at_activation: int

signal target_hit(target: Target, time: int)
signal inactive(target: Target)

# TODO see if is_hittable can be removed
# TODO rename on_missed_hit_opportunity


func _ready() -> void:
	assert(audio_player != null, "Audio Player is null in node " + name)
	assert(appear_sound != null, "Audio Player is null in node " + name)
	assert(click_sound != null, "Audio Player is null in node " + name)
	assert(click_area != null, "Click Area is null in node" + name)
	set_process_input(true)


func gamestart() -> void:
	is_hittable = false
	is_moving = false
	click_area.input_pickable = false


@abstract
func gameover() -> void


func emerge() -> void:
	is_moving = true
	is_hittable = true

	play_stimulus()
	click_area.input_pickable = true
	time_at_activation = Time.get_ticks_msec()


func on_click() -> void:
	if !is_hittable:
		return

	is_hittable = false
	target_hit.emit(self, Time.get_ticks_msec() - time_at_activation)
	click_area.input_pickable = false


@abstract
func submerge() -> void


func on_missed_hit_opportunity() -> void:
	is_moving = false
	inactive.emit(self)


func play_stimulus() -> void:
	const DURATION_MS := 100
	const AMPLITUDE := 0.25
	Input.vibrate_handheld(DURATION_MS, AMPLITUDE)
	play_audio(appear_sound)


func play_audio(audio: AudioStream) -> void:
	audio_player.stream = audio
	audio_player.play()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		on_click()
