#https://github.com/lulersoft/godot_mole_game
#Godot QQ Group: 302924317
#Author:xiaolu (QQ2604904)
extends AnimatedSprite2D

var is_moving := false
var is_hittable := false

var speed := 0.0
var original_pos: Vector2
var destination_pos: Vector2

var tween: Tween

signal mole_hit(mole: Node2D)
signal mole_missed(mole: Node2D)

const DELAY: float = 0.5
const TWEEN_TIME: float = 0.3


func _ready():
	original_pos = position
	destination_pos = Vector2(original_pos.x, original_pos.y - 60)
	set_process_input(true)
	tween = create_tween()


func gamestart():
	is_hittable = false
	is_moving = false
	position = original_pos


func gameover():
	tween.stop_all()


func onClick():
	if !is_hittable:
		return
	is_hittable = false
	tween.remove_all()
	tween.tween_callback(submerge).set_delay(DELAY)
	tween.start()

	get_node("anim").play("die")
	mole_hit.emit()


func emerge():
	is_moving = true
	is_hittable = true

	get_node("anim").play("run")
	tween.tween_property(self, "position", destination_pos, TWEEN_TIME)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_callback(emerge_complete).set_delay(DELAY)

	tween.start()


func emerge_complete():
	submerge()


func submerge():
	tween.tween_property(self, "position", original_pos, TWEEN_TIME)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.set_delay(DELAY)
	tween.tween_callback(on_missed_hit_opportunity).set_delay(TWEEN_TIME + DELAY)
	tween.start()


func on_missed_hit_opportunity():
	is_moving = false
	if is_hittable:
		mole_missed.emit(self)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		onClick()
