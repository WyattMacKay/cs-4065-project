extends Control

@export var whacamole_scene: PackedScene
@export var hci_scene: PackedScene
@export var id_edit: LineEdit


func _on_wipe_data_pressed() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Clear All User Data"
	dialog.dialog_text = "Are you sure you want to delete all collected data?"
	dialog.get_label().autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.min_size = Vector2(get_viewport_rect().size.x * 0.8, dialog.size.y)
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(DataCollector.clear_data)


func _on_whac_a_mole_button_pressed() -> void:
	set_scene(whacamole_scene)


func _on_hci_button_pressed() -> void:
	pass # Replace with function body.


func set_scene(scene: PackedScene):
	if id_edit.text.is_empty() or !id_edit.text.is_valid_int():
		return
	DataCollector.user_id = id_edit.text.to_int()
	get_tree().change_scene_to_packed(scene)
