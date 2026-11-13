extends Target

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
	pop_up()
	get_node("anim").play("die")


func emerge():
	super.emerge()
	get_node("anim").play("run")
	pop_up()


func pop_up() -> void:
	reset_tween()
	tween.tween_property(self, "position", destination_pos, TWEEN_TIME) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN)


func on_click():
	super.on_click()
	reset_tween()
	tween.tween_callback(submerge).set_delay(DELAY)
	get_node("anim").play("die")


func submerge():
	reset_tween()
	tween.tween_property(self, "position", original_pos, TWEEN_TIME) \
			.set_delay(DELAY) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN)

	tween.tween_callback(emit_inactive)


func end_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()


func reset_tween() -> void:
	end_tween()
	tween = create_tween()
