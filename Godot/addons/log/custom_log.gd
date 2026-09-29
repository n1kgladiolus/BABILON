extends Logger

func _log_message(message: String, error: bool) -> void:
	if error:
		IL.print(message)
		pass
	else:
		IL.print(message)

func _log_error(
	function_name: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	editor_notify: bool,
	error_type: int,
	script_backtraces: Array[ScriptBacktrace]
	) -> void:
	
	print("[ERROR CAPTURED] %s (%s:%d): %s" % [function_name, file, line, rationale])
