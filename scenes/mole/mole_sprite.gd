#https://github.com/lulersoft/godot_mole_game
#Godot QQ Group: 302924317
#Author:xiaolu (QQ2604904)
extends AnimatedSprite2D

class_name Target

var is_moving := false
var is_hittable := false

var original_pos: Vector2
var destination_pos: Vector2

var tween: Tween

signal target_hit(mole: Target)
signal inactive(mole: Target)

const DELAY: float = 0.3
const TWEEN_TIME: float = 0.1


func _ready():
	original_pos = position
	destination_pos = Vector2(original_pos.x, original_pos.y - 60)
	set_process_input(true)


func gamestart():
	is_hittable = false
	is_moving = false
	position = original_pos


func gameover():
	end_tween()


func on_click():
	if !is_hittable:
		return
	is_hittable = false
	reset_tween()

	tween.tween_callback(submerge).set_delay(DELAY)

	get_node("anim").play("die")
	target_hit.emit(self)


func emerge():
	reset_tween()

	is_moving = true
	is_hittable = true

	get_node("anim").play("run")
	tween.tween_property(self, "position", destination_pos, TWEEN_TIME) \
	.set_trans(Tween.TRANS_LINEAR) \
	.set_ease(Tween.EASE_IN)


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


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		on_click()
