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


func _ready():
	add_user_signal("hit on one mole", [TYPE_OBJECT])
	add_user_signal("missing one mole", [TYPE_OBJECT])
	original_pos = position
	destination_pos = Vector2(original_pos.x, original_pos.y - 60)
	set_process_input(true)
	tween = create_tween()


func gamestart():
	is_hittable = false
	is_moving = false
	position = original_pos
	tween.start()


func gameover():
	tween.stop_all()


func onClick():
	if !is_hittable:
		return
	is_hittable = false
	tween.remove_all()
	tween.interpolate_callback(self, 0.5, "comIn")
	tween.start()

	get_node("anim").play("die")
	emit_signal("hit on one mole", self)


func comeOut():
	is_moving = true
	is_hittable = true

	get_node("anim").play("run")
	var t = 0.3

	tween.interpolate_property(self, "position", position, destination_pos, t, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.interpolate_callback(self, t, "onOutcomplete")

	tween.start()


func onOutcomplete():
	comIn()


func comIn():
	var t = 0.3
	var delay = 0.5

	tween.interpolate_property(self, "position", position, original_pos, t, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	tween.interpolate_callback(self, t + delay, "onIncomplete")
	tween.start()


func onIncomplete():
	is_moving = false
	if is_hittable:
		emit_signal("missing one mole", self)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		onClick()
