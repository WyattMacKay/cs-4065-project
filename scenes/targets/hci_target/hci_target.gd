extends Target

@export var rect: ColorRect

var inactive_colour: Color
var active_colour: Color = Color(0.417, 0.77, 0.146, 1.0)


func _ready() -> void:
	super._ready()
	assert(rect != null, "Export variable Rect is null in" + name)
	inactive_colour = rect.color


func on_click() -> void:
	super.on_click()
	rect.color = inactive_colour


func emerge() -> void:
	super.emerge()
	rect.color = active_colour


func gameover() -> void:
	pass
