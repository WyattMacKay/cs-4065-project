@abstract

class_name Target

extends Node2D

@export var audio_player: AudioStreamPlayer
@export var appear_sound: AudioStream
@export var click_sound: AudioStream
@export var click_area: Area2D

var time_at_activation: int

signal target_hit(target: Target, time: int)
signal inactive(target: Target)


func _ready() -> void:
	assert(audio_player != null, "Audio Player is null in node " + name)
	assert(appear_sound != null, "Audio Player is null in node " + name)
	assert(click_sound != null, "Audio Player is null in node " + name)
	assert(click_area != null, "Click Area is null in node" + name)
	set_process_input(true)
	click_area.input_pickable = false


func gamestart() -> void:
	click_area.input_pickable = false


@abstract
func gameover() -> void


func emerge() -> void:
	play_stimulus()
	click_area.input_pickable = true
	time_at_activation = Time.get_ticks_msec()


func on_click() -> void:
	target_hit.emit(self, Time.get_ticks_msec() - time_at_activation)
	click_area.input_pickable = false
	play_audio(click_sound)


func emit_inactive() -> void:
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
