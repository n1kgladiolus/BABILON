extends Control

@onready var log_text: RichTextLabel = $ConsoleLayer/MarginContainer/Panel/VBoxContainer/Console
@onready var command_input: LineEdit = $ConsoleLayer/MarginContainer/Panel/VBoxContainer/Command

var my_logger: InlineLogger

func _init() -> void:
	my_logger = InlineLogger.new()
	my_logger.console_ui = self
	OS.add_logger(my_logger)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if "--server" in args or "--server_game" in args:
		queue_free()
		return
	else:
		pass
	#log_text.text = "Консоль инициализирована."
	$ConsoleLayer.visible = false
	
	command_input.text_submitted.connect(command_submitted)

func command_submitted(command):
	command = command.strip_edges()
	if command.is_empty():
		return
	command_input.clear()
	write_line("> " + command, "system")
	var parts = command.split("-", false)
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	match cmd:
		"server":
			if C.log_in_status:
				if C.USERNAME == "admin":
					var data = args
					C.send_player_command(data)
					print("Команда отправлена")
		_:
			write_line("Неизвестная команда: " + cmd, "error")
		
	



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		get_viewport().set_input_as_handled()
		$ConsoleLayer.visible = !$ConsoleLayer.visible
		if visible:
			command_input.grab_focus()
		else:
			command_input.release_focus()

func write_line(message: String, type: String = "info") -> void:
	var color: String = "white"
	match type:
		"warn": color = "yellow"
		"error": color = "red"
		"success": color = "green"
		"system": color = "gray"
		
	var formatted_msg: String = "[color=%s]%s[/color]\n" % [color, message]
	log_text.append_text(formatted_msg)

class InlineLogger extends Logger:
	var mutex: Mutex = Mutex.new()
	var console_ui: Control
	func _log_error(
		function: String, 
		file: String, 
		line: int, 
		code: String, 
		rationale: String, 
		editor_notify: bool, 
		error_type: int, 
		script_backtraces: Array[ScriptBacktrace]
	) -> void:
		mutex.lock()
		if is_instance_valid(console_ui):
			var error_msg: String = "Ошибка в %s() (%s:%d): %s" % [function, file.get_file(), line, rationale if not rationale.is_empty() else code]
			console_ui.call_deferred("write_line", error_msg, "error")
		mutex.unlock()
	func _log_message(message: String, error: bool) -> void:
		mutex.lock()
		if is_instance_valid(console_ui):
			var log_type: String = "error" if error else "info"
			console_ui.call_deferred("write_line", message.strip_edges(), log_type)
		mutex.unlock()
