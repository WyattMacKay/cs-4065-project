extends Node

const LOG_FILE := "user://game_data.csv"

# TODO reset data

var csv_header := PackedStringArray(
	[
		"User ID",
		"Data Collection Method",
		"Trial Number",
		"Trial Location",
		"Number of Misclicks",
		"Time",
	]
)


func append_data(
	collection_method: String,
	trial_number: int,
	trial_location: int,
	misclicks: int,
	time: int,
):
	var f: FileAccess

	if FileAccess.file_exists(LOG_FILE):
		f = FileAccess.open(LOG_FILE, FileAccess.READ_WRITE)
	else:
		f = FileAccess.open(LOG_FILE, FileAccess.WRITE_READ)

	if f == null:
		push_error("Failed to open CSV: " + str(FileAccess.get_open_error()))
		return

	if f.get_length() > 0:
		var existing_header = f.get_csv_line()

		if existing_header != csv_header:
			print("CSV format has changed. Restarting data collection.")

			f.close()
			f = FileAccess.open(LOG_FILE, FileAccess.WRITE_READ)

			if f == null:
				push_error("Failed to reset CSV.")
				return

	if f.get_length() == 0:
		f.store_csv_line(csv_header)

	f.seek_end()
	f.store_csv_line(
		PackedStringArray([collection_method, trial_number, trial_location, misclicks, time])
	)

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


func clear_data() -> void:
	DirAccess.remove_absolute(LOG_FILE)
