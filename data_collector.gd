extends Node

const LOG_FILE := "user://game_data.csv"


func append_data(misclicks: int, time: int):
	var access_code: FileAccess.ModeFlags = (
		FileAccess.READ_WRITE
		if FileAccess.file_exists(LOG_FILE)
		else FileAccess.WRITE_READ
	)
	var f := FileAccess.open(LOG_FILE, access_code)
	if (!f):
		var error = FileAccess.get_open_error()
		push_error("Failed to open CSV. Error code: " + str(error))
		push_error("User data directory: " + OS.get_user_data_dir())
		return
	f.seek_end()
	if (f.get_length() == 0):
		f.store_csv_line(PackedStringArray(["# of misclicks", "time"]))

	f.store_csv_line(PackedStringArray([misclicks, time]))
	f.flush()
	f.close()


func export() -> void:
	var error = DisplayServer.file_dialog_show(
		"Export CSV",
		"",
		"game_data.csv",
		false,
		DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,
		PackedStringArray(["*.csv;CSV Files;text/csv"]),
		_on_export_file_selected,
	)

	if error != OK:
		push_error("Could not open file picker: " + str(error))


func _on_export_file_selected(
	status: bool,
	selected_paths: PackedStringArray,
	_selected_filter_index: int,
) -> void:
	if not status or selected_paths.is_empty():
		return

	var source = FileAccess.open(LOG_FILE, FileAccess.READ)

	if source == null:
		push_error("Could not read CSV: " + str(FileAccess.get_open_error()))
		return

	var csv_contents = source.get_as_text()
	source.close()

	var destination = FileAccess.open(selected_paths[0], FileAccess.WRITE)

	if destination == null:
		push_error("Could not write exported CSV: " + str(FileAccess.get_open_error()))
		return

	destination.store_string(csv_contents)
	destination.close()

	print("CSV successfully exported!")
