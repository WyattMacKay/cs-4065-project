extends Control


func _on_wipe_data_pressed() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Clear All User Data"
	dialog.dialog_text = "Are you sure you want to delete all collected data?"
	dialog.get_label().autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.min_size = Vector2(get_viewport_rect().size.x * 0.8, dialog.size.y)
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(DataCollector.clear_data)
